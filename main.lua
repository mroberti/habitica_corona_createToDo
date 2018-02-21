math.randomseed( os.time() )
local json = require ("json")
local habiticaID = "<yourID>"
local habiticaAPIkey = "<yourKey>"

function getResponse( event )
    if ( event.isError ) then
        --Hostname not found?
        print("Error?")
    else
        print("Response"..json.prettify(event.response))
    end
end

function addTodoListItems(url, action, listOfItems, callback)
    local headers = {}
    print("Adding sub tasks in the ToDo list...")
    headers["Content-Type"] = "application/json"
    headers[ "x-api-user"] = habiticaID
    headers[ "x-api-key"] = habiticaAPIkey

    local params = {}
    local body = {}
    params.headers = headers
    local count = 1
    local function AddSubTask()
        params.body = json.encode(body)
        body["text"]=listOfItems[count]
        network.request ( "https://habitica.com/api/v3/tasks/"..url.."/checklist", action, callback, params )
        count=count+1
    end
    -- I do a delay of 100ms because
    -- in other APIs calling a bunch of
    -- functions all at once can freak it
    -- out sometimes.
    timer.performWithDelay( 100, AddSubTask,#listOfItems+1 )
end

function confirmToDoCreated( event )
    print("confirmToDoCreated...")
    if ( event.isError ) then
        --Hostname not found?
        print("Error?")
    else
        local table = json.decode( event.response )
        for k,v in pairs(table) do
            print(k,v)
        end
        print("The GUID of the table, "..table.data._id) -- needed for routing the subtasks to it!
        print("if you wanna mess with the same list later!!")
        -- Sub out the below with your own items
        local listOfItems = {"Milk","Eggs","Snausages","Whole wheat bread","OMFG PIZZA ROLLS","Salad"}
        addTodoListItems(table.data._id, "POST", listOfItems, getResponse)
    end
end

function CreateANewTodo(url, action, callback)
    local headers = {}

    headers["Content-Type"] = "application/json"
    headers[ "x-api-user"] = habiticaID
    headers[ "x-api-key"] = habiticaAPIkey

    local params = {}
    local body = {}
    body["text"]= "Shopping List 2" -- <-- The task name
    body["type"]= "todo" -- <-- Type is a to-do list (T)
    body["notes"]="A list for when I go to the store for groceries" -- <-- A little subtitle, this can be anything, optional
    body["priority"]= 2
    body["date"]="03/31/2018"
    params.headers = headers
    params.body = json.encode(body)
    network.request ( url, action, callback, params )
end

CreateANewTodo("https://habitica.com/api/v3/tasks/user", "POST", confirmToDoCreated)
