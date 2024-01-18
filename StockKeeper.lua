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
    print("Retrieved "..#items.." craftable items from RS")
    for itemIndex in pairs(items) do
        local item = items[itemIndex]
        current_stock[item.name] = item.amount
    end
end

function checkStock()
    for s in pairs(stock_list) do
        local name = stock_list[s].name
        local wantedAmount = stock_list[s].amount
        local current_amount = current_stock[name]
        if current_amount then
            print("Item: "..name.." Wanted: "..wantedAmount.." Current: "..current_amount)
            if current_amount < wantedAmount then
                bridge.craftItem({name=name, count=wantedAmount-current_amount})
            end
        else
            print("Item "..name.." not found in craftable items")
        end
    end
end

function addBricks()
    print("Adding bricks if no items")
    local brickName = "minecraft:stone_bricks"
    if not stock_list[brickName] then
        local brick = {name=brickName, amount=64}
        table.insert(stock_list, brick)
    end
end

--Print tables
function prtTable(tbl, prefix)
    prefix = prefix or ""
    
    for k, v in pairs(tbl) do
        print(prefix .. "k: " .. tostring(k) .. "; v: " .. tostring(v))

        if type(v) == "table" then
            prtTable(v, prefix .. "-") --add a dash for every level of recursion so we get a nice tree structure for nested tables
        end    
    end
end

--like prtTable but keeps the order of the table intact (cannot be used for associative arrays!)
function prtITable(tbl, prefix)
    prefix = prefix or ""
    
    for k, v in ipairs(tbl) do
        print(prefix .. "k: " .. tostring(k) .. "; v: " .. tostring(v))

        if type(v) == "table" then
            prtTable(v, prefix .. "-") --add a dash for every level of recursion so we get a nice tree structure for nested tables
        end    
    end
end

function work()
    getStockFromFile()
    getStockFromRS()
    addBricks()
    checkStock()
    writeStockToFile()
end

work()
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