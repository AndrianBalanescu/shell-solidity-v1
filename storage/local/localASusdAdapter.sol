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

import "../aaveResources/ILendingPoolAddressesProvider.sol";
import "../aaveResources/ILendingPool.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../LoihiRoot.sol";

contract LocalASUsdAdapter is LoihiRoot {

    IERC20 _asusd;

    constructor (address __asusd) public {
        _asusd = IERC20(__asusd);
    }

    // takes raw cdai amount
    // unwraps it into dai
    // deposits dai amount in chai
    function intakeRaw (uint256 amount) public returns (uint256) {

        asusd.transferFrom(msg.sender, address(this), amount);
        return amount;

    }

    function intakeNumeraire (uint256 amount) public returns (uint256) {

        asusd.transferFrom(msg.sender, address(this), amount);
        return amount;

    }

    function outputRaw (address dst, uint256 amount) public returns (uint256) {

        asusd.transfer(dst, amount);
        return amount;

    }

    // unwraps numeraire amount of dai from chai
    // wraps it into cdai amount
    // sends that to destination
    function outputNumeraire (address dst, uint256 amount) public returns (uint256) {

        asusd.transfer(dst, amount);
        return amount;

    }

    function viewRawAmount (uint256 amount) public view returns (uint256) {

        return amount;

    }

    function viewNumeraireAmount (uint256 amount) public view returns (uint256) {

        return amount;

    }

    function viewNumeraireBalance (address addr) public returns (uint256) {

        return _asusd.balanceOf(addr);

    }

    // takes raw amount and gives numeraire amount
    function getRawAmount (uint256 amount) public returns (uint256) {

        return amount;

    }

    // takes raw amount and gives numeraire amount
    function getNumeraireAmount (uint256 amount) public returns (uint256) {

        return amount;

    }

    function getNumeraireBalance () public returns (uint256) {
        
        return asusd.balanceOf(address(this));

    }

    uint constant WAD = 10 ** 18;
    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function wdivup(uint x, uint y) internal pure returns (uint z) {
        // always rounds up
        z = add(mul(x, WAD), sub(y, 1)) / y;
    }


}