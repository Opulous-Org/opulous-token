// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev OwnerOperator module which provides a basic control mechanism
 * to a contract for both an owner, and an operator.
 *
 * The operator provides day to day operations on the contract using
 * an account which, if compromised, can be changed by the operator.
 * 
 * The owner is only used to change the operator.
 */
abstract contract OwnerOperator {
    address private _owner;
    address private _operator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor ( address firstOperator ) {
    	_owner = msg.sender;
        _operator = firstOperator;
        emit OwnershipTransferred(address(0), _owner );
        emit OperatorTransferred(address(0), _operator);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current operator.
     */
    function operator() public view virtual returns (address) {
        return _operator;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require( owner() == msg.sender, "OwnerOperator: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require( operator() == msg.sender, "OwnerOperator: caller is not the operator");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "OwnerOperator: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`newOperator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address newOperator) public virtual onlyOwner {
        require(newOperator != address(0), "OwnerOperator: new operator is the zero address");
        emit OperatorTransferred(_operator, newOperator);
        _operator = newOperator;
    }
}