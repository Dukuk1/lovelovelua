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