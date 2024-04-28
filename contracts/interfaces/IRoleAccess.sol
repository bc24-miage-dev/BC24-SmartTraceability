pragma solidity ^0.8.20;

import "../libraries/categoryTypes.sol";

interface IRoleAccess {
    function onlyBreederRole(address sender) external view returns (bool);

    function onlyTransporterRole(address sender) external view returns (bool);

    function grantRoleToAddress(address account, string memory role) external;
}
