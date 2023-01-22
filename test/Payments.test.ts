import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { AutoPay, Array } from "../typechain-types"
import hardhat, { ethers } from "hardhat"
import { expect } from "chai"

describe("AutoPay", () => {
    /**
     * @DeclareWallet
     * - Owner
     * - Others
     */
    let owner: SignerWithAddress
    let manager: SignerWithAddress
    let senior: SignerWithAddress
    let midLevel: SignerWithAddress
    let junior: SignerWithAddress
    let addrs: SignerWithAddress[]

    /**
     * @DeclareSmartContracts
     * - Array
     * - AutoPay
     */
    let Array: Array
    let Pay: AutoPay

    describe("Wallet", async () => {
        it("Create Wallets", async () => {
            ;[owner, manager, senior, midLevel, junior, ...addrs] =
                await ethers.getSigners()
            for (let i = 0; i < addrs.length; i++) {
                await addrs[i].sendTransaction({
                    to: owner.address,
                    value: ethers.utils.parseEther("9999")
                })
            }
        })
    })

    describe("Deploy", async () => {
        it("Deploy AutoPay", async () => {
            const Lib = await hardhat.ethers.getContractFactory("Array")
            Array = await Lib.deploy()
            const PaymentFactory = await hardhat.ethers.getContractFactory(
                "AutoPay",
                {
                    libraries: {
                        Array: Array.address
                    }
                }
            )
            Pay = await PaymentFactory.deploy()
        })
    })

    describe("Employee", async () => {
        it("add Employee, salary: 10.000ETH, role: Manager", async () => {
            await expect(Pay.connect(owner).add(manager.address, 10000))
                .to.emit(Pay, "NewEmployee")
                .withArgs(manager.address, 10000, 172818)

            expect(await Pay.salary(manager.address)).to.equal(
                ethers.utils.parseEther("10000")
            )
            expect(await Pay.nextPayment(manager.address)).to.equal(172818)
        })
        it("add Employee, salary: 8.000ETH, role: Senior", async () => {
            await expect(Pay.connect(owner).add(senior.address, 8000))
                .to.emit(Pay, "NewEmployee")
                .withArgs(senior.address, 8000, 172819)
            expect(await Pay.salary(senior.address)).to.equal(
                ethers.utils.parseEther("8000")
            )
            expect(await Pay.nextPayment(senior.address)).to.equal(172819)
        })
        it("add Employee, salary: 4.000ETH, role: mid-level", async () => {
            await expect(Pay.connect(owner).add(midLevel.address, 4000))
                .to.emit(Pay, "NewEmployee")
                .withArgs(midLevel.address, 4000, 172820)
            expect(await Pay.salary(midLevel.address)).to.equal(
                ethers.utils.parseEther("4000")
            )
            expect(await Pay.nextPayment(midLevel.address)).to.equal(172820)
        })
        it("add Employee, salary: 2.000ETH, role: junior", async () => {
            await expect(Pay.connect(owner).add(junior.address, 2000))
                .to.emit(Pay, "NewEmployee")
                .withArgs(junior.address, 2000, 172821)
            expect(await Pay.salary(junior.address)).to.equal(
                ethers.utils.parseEther("2000")
            )
            expect(await Pay.nextPayment(junior.address)).to.equal(172821)
        })
        it("edit salary of Manager employee to 12.000ETH", async () => {
            await expect(Pay.connect(owner).edit(manager.address, 12000))
                .to.emit(Pay, "NewSalary")
                .withArgs(manager.address, 12000)
            expect(await Pay.salary(manager.address)).to.equal(
                ethers.utils.parseEther("12000")
            )
        })
        it("remove employee: Junior", async () => {
            await expect(Pay.connect(owner).remove(junior.address))
                .to.emit(Pay, "EmployeeRemoved")
                .withArgs(junior.address)
            expect(await Pay.salary(junior.address)).to.equal(0)
        })
        it("should be throw error when add exists employee", async () => {
            await expect(Pay.connect(owner).add(junior.address, 2000)).to.be
                .reverted
        })
        it("get all Employee", async () => {
            const employees = await Pay.connect(owner).employees()
            const testEmployees = [
                manager.address,
                senior.address,
                midLevel.address,
                junior.address
            ]

            expect(employees).to.be.a("array")
            expect(employees).to.be.length(4)
            expect(employees).to.have.members(testEmployees)
        })
    })

    describe("Deposit", async () => {
        it("cust of all employees should be 24.000 ETH", async () => {
            const custOfAllEmployees = await Pay.totalCost()
            expect(custOfAllEmployees).to.equal(
                ethers.utils.parseEther("24000")
            )
        })
        it("add 24.001 ETH for pay employees", async () => {
            await Pay.connect(owner).deposit({
                value: ethers.utils.parseEther("24001")
            })
            expect(await Pay.connect(manager).balance()).to.equal(
                ethers.utils.parseEther("24001")
            )
        })
    })

    describe("Payment", async () => {
        it("pay employes", async () => {
            await hardhat.network.provider.send("hardhat_mine", [
                ethers.utils.hexValue(200000)
            ])
            const managerBalance = await manager.getBalance()
            const seniorBalance = await senior.getBalance()
            const midLevelBalance = await midLevel.getBalance()
            const juniorBalance = await junior.getBalance()

            await Pay.pay()

            expect(managerBalance).to.lessThan(await manager.getBalance())
            expect(seniorBalance).to.lessThan(await senior.getBalance())
            expect(midLevelBalance).to.lessThan(await midLevel.getBalance())
            expect(juniorBalance).to.equal(await junior.getBalance())
        })
    })
})
