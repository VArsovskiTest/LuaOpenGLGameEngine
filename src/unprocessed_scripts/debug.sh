#!/bin/bash
echo "🔍 PQUEUE DEBUGGER - RUNNING..."
echo "================================"

# 1. CHECK LINE 13
echo "1️⃣ LINE 13 of pqueue.lua:"
sed -n '13p' pqueue.lua 2>/dev/null || echo "❌ FILE MISSING!"
echo "   SHOULD BE: t.max = function()"
echo

# 2. CHECK require line
echo "2️⃣ First line of pqueue_test.lua:"
head -1 pqueue_test.lua 2>/dev/null || echo "❌ TEST FILE MISSING!"
echo "   SHOULD BE: local pqueue = require(\"pqueue\")"
echo

# 3. CHECK FILES EXIST
echo "3️⃣ File check:"
ls -la pqueue.lua pqueue_test.lua 2>/dev/null || echo "❌ FILES NOT FOUND!"
echo

# 4. AUTO-FIX BUTTON (press Y to fix everything)
echo "4️⃣ AUTO-FIX? (y/N): "
read -r fix
if [[ $fix =~ ^[Yy]$ ]]; then
    echo "🔧 AUTO-FIXING..."
    
    # Create FIXED pqueue.lua
    cat > pqueue.lua << 'EOF'
local ti = table.insert
local tr = table.remove
local tr2 = function(t,v)
	for i = 1,#t do
		if t[i]==v then
			tr(t,i)
			break
		end
	end
end

return function pqueue()
	local t={}
	local set={}
	local r_set={}
	local keys={}
	
	local addKV = function(k,v)
		set[k]=v
		if not r_set[v] then
			ti(keys,v)
			table.sort(keys)
			local k0={k}
			r_set[v]=k0
			setmetatable(k0, {__mode='v'})
		else
			ti(r_set[v],k)
		end
	end
	t.addKV = addKV
	
	local remove = function(k)
		local v = set[k]
		local prioritySet = r_set[v]
		tr2(prioritySet, k)
		if #prioritySet < 1 then
			tr2(keys, v)
			r_set[v] = nil
			table.sort(keys)
			set[k]=nil
		end
	end
	t.remove = remove
	
	t.min = function()
		local priority = keys[1]
		if priority then
			return r_set[priority][1] or {}
		else
			return {}
		end
	end
	
	t.max = function()
		local priority = keys[#keys]
		if priority then
			return r_set[priority][1] or {}
		else
			return {}
		end
	end
	
	t.empty = function()
		return #keys < 1
	end
	
	t.iterator = function()
		return function()
			if not t.empty() then
				local element = t.max()
				t.remove(element)
				return element
			end
		end
	end

	setmetatable(t, {__index = set,
	__newindex = function(t,k,v)
		if not set[k] then
			addKV(k, v)
		else
			remove(k)
			addKV(k, v)
		end
	end
	})

	return t
end
EOF

    # Create FIXED test
    cat > pqueue_test.lua << 'EOF'
local pqueue = require("pqueue")

local q = pqueue()

q:addKV(1,1)
q:addKV(2,2)
q:addKV(3,2)
q:addKV(4,3)
q:addKV(5,1)
q:addKV(6,3)

print(q:min())
print(q:max())
print(q:empty())

for element in q:iterator() do
	print(element)
end

print(q:empty())
EOF

    echo "✅ FIXED BOTH FILES!"
fi

# 5. FINAL TEST
echo "5️⃣ TESTING..."
echo "================================"
lua pqueue_test.lua
echo "================================"
echo "✅ DONE! If you see numbers 1-6, IT WORKS!"
