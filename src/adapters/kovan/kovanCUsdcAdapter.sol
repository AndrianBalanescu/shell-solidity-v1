
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.12;

import "../../interfaces/ICToken.sol";

contract KovanCUsdcAdapter {

    constructor () public { }

    ICToken constant cusdc = ICToken(0xcfC9bB230F00bFFDB560fCe2428b4E05F3442E35);
    
    // takes raw cusdc amount and transfers it in
    function intakeRaw (uint256 amount) public {
        cusdc.transferFrom(msg.sender, address(this), amount);
    }
    
    // takes numeraire amount and transfers corresponding cusdc in
    function intakeNumeraire (uint256 amount) public returns (uint256) {
        uint256 rate = cusdc.exchangeRateCurrent();
        amount = wdiv(amount / 1000000000000, rate);
        cusdc.transferFrom(msg.sender, address(this), amount);
        return amount;
    }

    // takes numeraire amount
    // transfers corresponding cusdc to destination
    function outputNumeraire (address dst, uint256 amount) public returns (uint256) {
        uint256 rate = cusdc.exchangeRateCurrent();
        amount = wdiv(amount / 1000000000000, rate);
        cusdc.transfer(dst, amount);
        return amount;
    }

    // takes raw amount
    // transfers that amount to destination
    function outputRaw (address dst, uint256 amount) public returns (uint256) {
        cusdc.transfer(dst, amount);
        return amount;
    }

    function viewRawAmount (uint256 amount) public view returns (uint256) {
        amount /= 1000000000000;
        uint256 rate = cusdc.exchangeRateStored();
        return wdiv(amount, rate);
    }

    function viewNumeraireAmount (uint256 amount) public view returns (uint256) {
        uint256 rate = cusdc.exchangeRateStored();
        return wmul(amount, rate) * 1000000000000;

    }

    function viewNumeraireBalance (address addr) public view returns (uint256) {
        uint256 rate = cusdc.exchangeRateStored();
        uint256 balance = cusdc.balanceOf(addr);
        return wmul(balance, rate) * 1000000000000;
    }

    // takes raw cusdc amount
    // returns corresponding numeraire amount
    function getRawAmount (uint256 amount) public returns (uint256) {
        uint256 rate = cusdc.exchangeRateCurrent();
        return wdiv(amount /1000000000000 , rate);
    }

    // takes raw cusdc amount
    // returns corresponding numeraire amount
    function getNumeraireAmount (uint256 amount) public returns (uint256) {
        uint256 rate = cusdc.exchangeRateCurrent();
        return wmul(amount, rate) * 1000000000000;
    }

    // returns numeraire amount of balance
    function getNumeraireBalance () public returns (uint256) {
        return cusdc.balanceOfUnderlying(address(this)) * 1000000000000;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), 1000000000000000000 / 2) / 1000000000000000000;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, 1000000000000000000), y / 2) / y;
    }
}