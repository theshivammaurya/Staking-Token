// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract createToken is ERC20{
    uint256 constant _totalSupply = 100 * 1e18;

constructor()ERC20("Ironman","IRM"){
  _mint(msg.sender, _totalSupply);
}
}