function fib(n)
    local a, b = 0, 1
    local fibs = {}
    for i = 1, n do
        table.insert(fibs, a)
        a, b = b, a + b
    end
    return fibs
end


for index, value in ipairs(fib(100)) do
    print(value)
end

-- if dir == 0 then 
--     love.graphics.line(px, py+size, px+size, py)--right
-- elseif dir == 1 then   
--     love.graphics.line(px, py, px+size, py+size)--top
-- elseif dir == 2 then  
--     love.graphics.line(px, py+size, px+size, py)--left
-- else                   
--      love.graphics.line(px, py, px+size, py+size) -- bottom
-- end