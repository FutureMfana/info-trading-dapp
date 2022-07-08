import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

const stdlib = loadStdlib(); //loads the appropriate network-specific Reach standard library

const accAlice = await stdlib.newTestAccount(stdlib.parseCurrency(100)); //initialize new test accounts for Alice
const accBob = await stdlib.newTestAccount(stdlib.parseCurrency(100)); //initialize new test accounts for Bob

const ctcAlice = accAlice.contract(backend); //Alice deploy the contract on the consensus network
const ctcBob = accBob.contract(backend, ctcAlice.getInfo()); //Bob attach to the contract

// Below code launch the backends and wait for their completion
await Promise.all([
    ctcAlice.participants.Alice({ //run the Alice participant backend and passes an object which holds the interact functions
        request: stdlib.parseCurrency(5), //requesting funds
        info: 'If you were these, you can see the beyond evil illusions.', //information to trade
    }), //initializing and interfacing participant Alice
    ctcBob.participants.Bob({
        want: (amt) => console.log(`Alice asked Bob for ${stdlib.formatCurrency(amt)}`),
        got: (secret) => console.log(`Alice's secret is: ${secret}`),
    }), //initializing and interfacing participant Bob
]);