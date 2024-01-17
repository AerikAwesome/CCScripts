local bridge = peripheral.find("rsBridge")
if not bridge then error("RS Bridge not found.") end
print("RS Bridge initialized.")

local stockFile = "stock.csv"
local stock_list = {}
local current_stock = {}

function getStockFromFile()
    print("Getting stock config from file")
    if fs.exists(stockFile) then
        local file = fs.open(stockFile, "r")
        stock_list = textutils.unserialise(file.readAll())
        file.close()
    end
end

function writeStockToFile()
    print("Writing stock config to file")
    local file = fs.open(stockFile, "w")
    file.write(textutils.serialise(stock_list))
    file.close()
end

function getStockFromRS()
    local items = bridge.listCraftableItems()
    for index, item in ipairs(items) do
        current_stock[item.name] = item.amount
    end
    print("Found "..#current_stock.." craftable items")
end

function checkStock()
    for s in pairs(stock_list) do
        local name = stock_list[s].name
        local wantedAmount = stock_list[s].amount
        local currentAmount = current_stock[name].amount
        print("Item: "..name.." Wanted: "..wantedAmount.." Current: "..currentAmount)
        if currentAmount < wantedAmount then
            bridge.craftItem({name=name, count=wantedAmount-currentAmount})
        end
    end
end

function addBricks()
    print("Adding bricks if no items")
    local brickName = "minecraft:stone_bricks"
    if #stock_list == 0 then
        local brick = {name=brickName, amount=64}
        table.insert(stock_list, brick)
    end
end

function work()
    getStockFromFile()
    getStockFromRS()
    addBricks()
    checkStock()
    writeStockToFile()
end


local delay = 10
local TIMER = os.startTimer(delay)
while true do
    local e = {os.pullEvent()}
    if e[1] == "timer" and e[2] == TIMER then
        now = os.time()
        work()
        TIMER = os.startTimer(delay)
    end
end