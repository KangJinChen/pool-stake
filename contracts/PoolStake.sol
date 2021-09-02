// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PoolStake is Ownable {

    uint256 public totalAllocPoints = 0;
    // pid corresponding address
    mapping(address => uint256) public pidOfPool;


    event PoolAdded(address indexed stakedToken, uint256 allocPoint);

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP/Single tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
    }

    // Info of each pools.
    struct PoolInfo {
        IERC20 stakedToken;           
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 totalStakedAddress;
        uint256 totalAmount;
    }

    PoolInfo[] public poolInfo;
    // Info of each user that stakes tokens corresponding pid
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Is staked address corresponding pid
    mapping (uint256 => mapping (address => bool)) isStakedAddress;


    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function addPool(
        IERC20[] memory stakedTokens,
        uint256[] memory allocPoints,
        bool _withUpdate
    ) public onlyOwner {
        require(
            stakedTokens.length == allocPoints.length
            "Pool Stake: Invalid length of pools"
        );
        for(uint i = 0; i < stakedTokens.length; i++) {
            _addPool(stakedTokens[i], allocPoints[i], _withUpdate);
        }
    }



    // ======== INTERNAL METHODS ========= //
    function _addPool( 
        IERC20 _stakedToken,
        uint256 _allocPoint, 
        bool _withUpdate
    ) internal {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoints = totalAllocPoints.add(_allocPoint);
        poolInfo.push(PoolInfo({
            stakedToken: _stakedToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            totalAmount: 0,
            totalStakedAddress: 0
        }));
        pidOfPool[address(_stakedToken)] = poolInfo.length - 1;
        emit PoolAdded(address(_stakedToken), _allocPoint);
    }

    
}