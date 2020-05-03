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

pragma solidity ^0.5.0;

import "../../interfaces/ICToken.sol";
import "../../LoihiRoot.sol";

contract LocalCUsdcAdapter is LoihiRoot {

    ICToken _cusdc;

    constructor (address __cusdc) public {
        _cusdc = ICToken(__cusdc);
    }

    // takes raw cusdc amount and transfers it in
    function intakeRaw (uint256 amount) public returns (uint256) {

        bool success = cusdc.transferFrom(msg.sender, address(this), amount);

        if (!success) {
            if (cusdc.balanceOf(msg.sender) < amount) revert("CUsdc/insufficient-balance");
            else revert("CUsdc/transferFrom-failed");
        }

        uint256 rate = cusdc.exchangeRateCurrent();
        return wmul(amount, rate) * 1000000000000;

    }
    
    // takes numeraire amount and transfers corresponding cusdc in
    function intakeNumeraire (uint256 amount) public returns (uint256) {

        uint256 rate = cusdc.exchangeRateCurrent();
        uint256 cusdcAmount = wdiv(amount / 1000000000000, rate);

        bool success = cusdc.transferFrom(msg.sender, address(this), cusdcAmount);

        if (!success) {
            if (cusdc.balanceOf(msg.sender) < cusdcAmount) revert("CUsdc/insufficient-balance");
            else revert("CUsdc/transferFrom-failed");
        }

        return cusdcAmount;

    }

    // takes numeraire amount
    // transfers corresponding cusdc to destination
    function outputNumeraire (address dst, uint256 amount) public returns (uint256) {

        uint256 rate = cusdc.exchangeRateCurrent();
        amount = wdiv(amount / 1000000000000, rate);

        bool success = cusdc.transfer(dst, amount);

        if (!success) {
            if (cusdc.balanceOf(msg.sender) < amount) revert("CUsdc/insufficient-balance");
            else revert("CUsdc/transfer-failed");
        }

        return amount;

    }

    // takes raw amount
    // transfers that amount to destination
    function outputRaw (address dst, uint256 amount) public returns (uint256) {

        bool success = cusdc.transfer(dst, amount);

        if (!success) {
            if (cusdc.balanceOf(msg.sender) < amount) revert("CUsdc/insufficient-balance");
            else revert("CUsdc/transfer-failed");
        }

        uint256 rate = cusdc.exchangeRateStored();

        return wmul(amount, rate) * 1000000000000;

    }

    function viewRawAmount (uint256 amount) public returns (uint256) {

        amount /= 1000000000000;
        uint256 rate = _cusdc.exchangeRateStored();
        return wdiv(amount, rate);

    }

    function viewNumeraireAmount (uint256 amount) public returns (uint256) {

        uint256 rate = _cusdc.exchangeRateStored();
        return wmul(amount, rate) * 1000000000000;

    }

    function viewNumeraireBalance (address addr) public returns (uint256) {

        uint256 rate = _cusdc.exchangeRateStored();
        uint256 balance = _cusdc.balanceOf(addr);
        return wmul(balance, rate) * 1000000000000;

    }

    // takes raw cusdc amount
    // returns corresponding numeraire amount
    function getRawAmount (uint256 amount) public returns (uint256) {

        uint256 rate = cusdc.exchangeRateCurrent();
        return wdiv(amount / 1000000000000, rate);

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