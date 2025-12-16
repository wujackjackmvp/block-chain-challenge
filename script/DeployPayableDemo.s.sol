// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./BaseScript.s.sol";
import "../src/PayableDemo.sol";
contract DeployPayableDemo is BaseScript {
    function run() public broadcaster {
        
        PayableDemo payableDemo = new PayableDemo();
        
       saveContract("payableDemo", address(payableDemo));
    }
}