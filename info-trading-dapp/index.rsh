'reach 0.1';
'use strict';

export const main = Reach.App(() => {
    const Alice = Participant('Alice', {
        //has information bob will require at some defined price
        request: UInt,
        info: Bytes(128),
    });
    const Bob = Participant('Bob', {
        want: Fun([UInt], Null),
        got: Fun([Bytes(128)], Null),
    });
    init();

    Alice.only(() => {
        //declassify make the request public, otherwise the request would remain private
        const request = declassify(interact.request)
    });
    //publish joins the app request value
    Alice.publish(request);
    commit();

    /*
     * At this point, Bob's backend has learned the value of request and can deliver it to Bob's
     * frontend for his approval. This happens next.
     */

    Bob.only(() => {
        //bob joins the app and commits to the contract (decides if he can pay the requested amount)
        interact.want(request);
    });
    //bob submits the payment
    Bob.pay(request);
    commit();

    /**
     * Trade is about to happen from here
     * Alice will recieve the tokens and release information required by bob
     */
    Alice.only(() => {
        const info = declassify(interact.info);
    });
    Alice.publish(info);
    transfer(request).to(Alice); //requested amount is transfered to Alice
    commit();

    /**
     * Trading continues
     * Bob recives the information on his frontend after sending the requested amount
     */
    Bob.only(() => {
        interact.got(info);
    });
    exit();
});