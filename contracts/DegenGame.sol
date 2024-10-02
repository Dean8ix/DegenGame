// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenGame is ERC20, Ownable {
    DegenItem[] public allItems;

    struct Player {
        address playerAddress;
        bool isRegistered;
    }

    struct DegenItem {
        address owner;
        uint8 itemId;
        string itemName;
        uint256 worth;
    }

    mapping(address => Player) public players;
    mapping(uint8 => DegenItem) public degenItems;
    mapping(address => mapping(uint8 => DegenItem)) public playerItems;

    event PlayerRegisters(address player, bool success);
    event Transfered(address sender, address recipient, uint256 amount);
    event TokenBurnt(address owner, uint256 amount);
    event ItemCreated(address owner, uint8 _itemId, string _itemName);
    event PropRedeemed(address newOwner, uint8 itemId, string itemName);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {
        addDegenItem(1, "Item1", 200);
        addDegenItem(2, "Item2", 400);
        addDegenItem(3, "Item3", 500);
    }

    function addressZeroCheck() private view {
        if (msg.sender == address(0)) revert ZERO_ADDRESS_NOT_ALLOWED();
    }

    function isRegistered(address _user) private view {
        if (!players[_user].isRegistered) revert NOT_REGISTERED(_user);
    }

    function playerRegister() external {
        if (players[msg.sender].playerAddress != address(0))
            revert YOU_HAVE_REGISTERED();

        Player storage _player = players[msg.sender];
        _player.playerAddress = msg.sender;
        _player.isRegistered = true;

        emit PlayerRegisters(msg.sender, true);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        isRegistered(_to);
        _mint(_to, _amount);
    }

    function transferToken(address _recipient, uint256 _amount)
        external
        returns (bool)
    {
        isRegistered(msg.sender);
        if (_recipient == address(0)) revert CANNOT_TRANSFER_ADDRESS_ZERO();
        if (!players[_recipient].isRegistered) revert NOT_REGISTERED(_recipient);

        if (transfer(_recipient, _amount)) {
            emit Transfered(msg.sender, _recipient, _amount);
            return true;
        }

        revert TRANSFER_FAILED();
    }

    function getBalance() external view returns (uint256) {
        isRegistered(msg.sender);
        return balanceOf(msg.sender);
    }

    function burnToken(uint256 _amount) external {
        isRegistered(msg.sender);

        _burn(msg.sender, _amount);

        emit TokenBurnt(msg.sender, _amount);
    }

    function addDegenItem(uint8 _itemId, string memory _itemName, uint256 _amount)
        private 
        
    {
        DegenItem storage _degenItem = degenItems[_itemId];

        _degenItem.owner = address(this);
        _degenItem.itemId = _itemId;
        _degenItem.itemName = _itemName;
        _degenItem.worth = _amount;

        allItems.push();

        emit ItemCreated(address(this), _itemId, _itemName);
    }

    function playerRedeemItem(uint8 _itemId) external {
        isRegistered(msg.sender);

        DegenItem storage _degenItem = degenItems[_itemId];

        uint256 _amount = _degenItem.worth;

        if (balanceOf(msg.sender) < _amount) revert INSUFFICIENT_BALANCE();

        transfer(address(this), _amount);

        _degenItem.owner = msg.sender;

        playerItems[msg.sender][_itemId] = _degenItem;

        emit PropRedeemed(msg.sender, _itemId, _degenItem.itemName);
    }
}

error ZERO_ADDRESS_NOT_ALLOWED();
error MAXIMUM_TOKEN_SUPPLY_REACHED();
error INSUFFICIENT_ALLOWANCE_BALANCE();
error INSUFFICIENT_BALANCE();
error ONLY_OWNER_IS_ALLOWED();
error BALANCE_MORE_THAN_TOTAL_SUPPLY();
error CANNOT_BURN_ZERO_TOKEN();
error ONLY_OWNER_OF_THE_ERC20_CAN_DEPLOY_THIS_CONTRACT();
error YOU_HAVE_REGISTERED();
error OWNER_CANNOT_REGISTER();
error N0_PLAYERS_TO_REWARD();
error YOU_CANNOT_TRANSFER_TO_ADDRESS_ZERO();
error TRANSFER_FAILED();
error NOT_REGISTERED(address);
error PLAYER_DOES_NOT_EXIST();
error PLAYER_NOT_SUSPENDED();
error PROP_DOES_NOT_EXIST();
error THE_RECEIVER_IS_NOT_A_PLAYER();
error CANNOT_TRANSFER_ADDRESS_ZERO();
