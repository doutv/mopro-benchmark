pragma circom 2.0.6;
include "./ecdsa_verify.circom";
component main { public [TPreComputes, U] } = ECDSAVerify(64, 4);