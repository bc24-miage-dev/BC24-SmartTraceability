from web3 import Web3
from web3.middleware import geth_poa_middleware
from eth_account import Account
import json

# CHANGE THIS EVERYTIME YOU REDEPLOY THE CONTRACT!!!
# Address of the deployed smart contract 
contract_address = '0xf5059a5D33d5853360D16C683c16e67980206f36'

# Connect to an Ethereum node
web3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

# Verify if the connection is successful
if web3.is_connected():
    print("-" * 50)
    print("Connection Successful")
    print("-" * 50)
else:
    print("Connection Failed")


# Wallet address allowed to call the createToken function
allowed_wallet_address = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

# Initialize address nonce
nonce = web3.eth.get_transaction_count(allowed_wallet_address)

with open('../artifacts/contracts/BC24.sol/BC24.json') as f:
    contract_json = json.load(f)

# Instantiate the contract without the ABI
contract = web3.eth.contract(
    address=contract_address, abi=contract_json['abi'])


# Testing the creation with address
contract.functions.createToken(allowed_wallet_address).transact({
    'from': allowed_wallet_address})

# Testing the creation with address --> if addBreedingInfo has onlyRole(MINTER_ROLE), otherwise it wont work
contract.functions.addBreedingInfo(0, "Cow", "Zurich", "male", 300, "healthy").transact({
    'from': allowed_wallet_address})

print(contract.functions.getMetaData(0).call())
