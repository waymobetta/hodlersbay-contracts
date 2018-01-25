const HodlersBay = artifacts.require('HodlersBay')
const sha3 = require('solidity-sha3').default
const {soliditySHA3} = require('ethereumjs-abi')

contract('HodlersBay', (accounts) => {
	// let HodlersBay
	// beforeEach('setup contract for each test', async function() {
	// 	HodlersBay = await HodlersBay.new(owner)
	// })
	it('should set the first account as the contract creator', async () => {
		const contract = await HodlersBay.deployed()
		const contractOwner = await contract.owner()

		assert.equal(contractOwner, accounts[0], 'main account is the creator')
	})
	it('should store 5 ether in smart contract with 0 second timelock', async () => {
		const contract = await HodlersBay.deployed()
		const sender = accounts[1]
		const tx = {
			value: 5e+18,
			from: sender
		}
		await contract.store.sendTransaction(0, tx)
		const myHodlersBayBal = await contract.hodlersBayBalance.call(sender)
		assert.equal(myHodlersBayBal.c[0]/10000, 5, 'stores 5 ether with 0 second timelock')
	})
	it('should check to see if [0 second] timelock is in place', async () => {
		const contract = await HodlersBay.deployed()
		const timeLock = await contract.isTimeUp.call()
		assert.equal(timeLock, true, 'timelock is up')
	})
	it('should dispense 4 ether from smart contract', async () => {
		const contract = await HodlersBay.deployed()
		const sender = accounts[1]
		const tx = {
			from: sender
		}
		await contract.withdraw.sendTransaction(4, tx)
		const myHodlersBayBal	= await contract.hodlersBayBalance.call(sender)
		assert.equal(myHodlersBayBal.c[0]/10000, 1, 'dispenses 4 ether from contract')
	})
})
