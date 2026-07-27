import { readFileSync } from "fs";
import { execSync } from "child_process";
import { createHash } from "crypto";

function lnCli(node: string, command: string): any {
    const result = execSync(`docker exec ${node} lightning-cli --network=regtest ${command}`, {
        encoding: 'utf-8'
    });
    return JSON.parse(result);
}

describe('Evaluate submission', () => {
    let paymentHash: string;
    let preimage: string;
    let bolt11: string;
    let payerId: string;
    let payeeId: string;
    let feeMsat: number;
    let bobForwardedHash: string;

    it('should read and parse out.txt with 7 lines', () => {
        const lines = readFileSync('out.txt', 'utf-8').trim().split('\n');
        expect(lines).toHaveLength(7);

        paymentHash = lines[0].trim();
        preimage = lines[1].trim();
        bolt11 = lines[2].trim();
        payerId = lines[3].trim();
        payeeId = lines[4].trim();
        feeMsat = parseInt(lines[5].trim(), 10);
        bobForwardedHash = lines[6].trim();

        expect(paymentHash).toBeTruthy();
        expect(preimage).toBeTruthy();
        expect(bolt11).toBeTruthy();
        expect(payerId).toBeTruthy();
        expect(payeeId).toBeTruthy();
        expect(feeMsat).toBeDefined();
        expect(bobForwardedHash).toBeTruthy();
    });

    it('should have valid payment hash format (64 hex characters)', () => {
        expect(paymentHash).toMatch(/^[a-f0-9]{64}$/);
    });

    it('should have valid preimage format (64 hex characters)', () => {
        expect(preimage).toMatch(/^[a-f0-9]{64}$/);
    });

    it('should have valid BOLT11 invoice format', () => {
        expect(bolt11).toMatch(/^lnbcrt/i);
        expect(bolt11.length).toBeGreaterThan(100);
    });

    it('should have SHA256(preimage) equal payment hash', () => {
        const hash = createHash('sha256')
            .update(Buffer.from(preimage, 'hex'))
            .digest('hex');
        expect(hash).toBe(paymentHash);
    });

    it('should have Bob forwarded payment hash match payment hash', () => {
        expect(bobForwardedHash).toMatch(/^[a-f0-9]{64}$/);
        expect(bobForwardedHash).toBe(paymentHash);
    });

    it('should verify payment is complete via Alice', () => {
        const pays = lnCli('alice', `listpays`);
        const pay = pays.pays.find((p: any) => p.payment_hash === paymentHash);

        expect(pay).toBeDefined();
        expect(pay.status).toBe('complete');
    });

    it('should verify invoice is paid via Carol', () => {
        const invoices = lnCli('carol', 'listinvoices');
        const invoice = invoices.invoices.find((inv: any) => inv.payment_hash === paymentHash);

        expect(invoice).toBeDefined();
        expect(invoice.status).toBe('paid');
        expect(invoice.amount_msat).toBe(100000000);
    });

    it('should verify Alice has a channel with Bob', () => {
        const aliceChannels = lnCli('alice', 'listpeerchannels');
        const bobInfo = lnCli('bob', 'getinfo');

        const channelWithBob = aliceChannels.channels.find(
            (ch: any) => ch.peer_id === bobInfo.id
        );

        expect(channelWithBob).toBeDefined();
        expect(channelWithBob.state).toBe('CHANNELD_NORMAL');
    });

    it('should verify Bob has a channel with Carol', () => {
        const bobChannels = lnCli('bob', 'listpeerchannels');
        const carolInfo = lnCli('carol', 'getinfo');

        const channelWithCarol = bobChannels.channels.find(
            (ch: any) => ch.peer_id === carolInfo.id
        );

        expect(channelWithCarol).toBeDefined();
        expect(channelWithCarol.state).toBe('CHANNELD_NORMAL');
    });

    it('should verify Bob forwarded the payment', () => {
        const forwards = lnCli('bob', 'listforwards');
        const forward = forwards.forwards.find(
            (f: any) => f.status === 'settled'
        );

        expect(forward).toBeDefined();
        expect(forward.status).toBe('settled');
        expect(parseInt(forward.fee_msat)).toBeGreaterThanOrEqual(0);

        const htlcs = lnCli('bob', 'listhtlcs');
        const htlc = htlcs.htlcs.find(
            (h: any) => h.payment_hash === paymentHash
        );
        expect(htlc).toBeDefined();
        expect(htlc.payment_hash).toBe(paymentHash);
    });
});
