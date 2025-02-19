---
title: "Go标准库 - container包与sort包"
date: 2025-02-19
draft: false
tags: ["go", "标准库"]
---

# Go标准库 - container包与sort包

## sort包

`sort`包提供了用于对切片和用户定义的集合进行排序的功能。它支持对基本数据类型和用户自定义集合的排序。

### 结构和方法

```go
// 基础接口
type Interface interface {
    Len() int           // 集合中的元素数量
    Less(i, j int) bool // 第i个元素是否应排在第j个元素前面
    Swap(i, j int)      // 交换第i个和第j个元素
}

// 主要函数
func Sort(data Interface)                        // 对数据进行排序
func Stable(data Interface)                      // 稳定排序
func IsSorted(data Interface) bool               // 判断是否已经排序
func Reverse(data Interface) Interface           // 返回逆序排序的包装器
func Search(n int, f func(int) bool) int        // 二分查找

// 切片排序
func Slice(x any, less func(i, j int) bool)     // 使用less函数对切片进行排序
func SliceStable(x any, less func(i, j int) bool) // 稳定排序版本
func SliceIsSorted(x any, less func(i, j int) bool) bool // 判断切片是否已排序

// 基本类型切片排序
func Float64s(x []float64)                      // 浮点数切片排序
func Float64sAreSorted(x []float64) bool        // 判断浮点数切片是否已排序
func Ints(x []int)                              // 整数切片排序
func IntsAreSorted(x []int) bool                // 判断整数切片是否已排序
func Strings(x []string)                        // 字符串切片排序
func StringsAreSorted(x []string) bool          // 判断字符串切片是否已排序
```

### 使用示例

1. 基本排序（使用 `sort.Slice`）：
```go
package main

import (
    "fmt"
    "sort"
)

func main() {
    people := []struct {
        Name string
        Age  int
    }{
        {"Bob", 31},
        {"John", 42},
        {"Michael", 17},
        {"Jenny", 26},
    }

    // 使用 sort.Slice 进行排序
    sort.Slice(people, func(i, j int) bool {
        return people[i].Age < people[j].Age
    })
    fmt.Println("按年龄升序:", people)

    // 反向排序
    sort.Slice(people, func(i, j int) bool {
        return people[i].Age > people[j].Age
    })
    fmt.Println("按年龄降序:", people)
}
```

2. 实现 `sort.Interface`（传统方式）：
```go
type Person struct {
    Name string
    Age  int
}

// ByAge 实现 sort.Interface
type ByAge []Person

func (a ByAge) Len() int           { return len(a) }
func (a ByAge) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByAge) Less(i, j int) bool { return a[i].Age < a[j].Age }

func main() {
    people := []Person{
        {"Bob", 31},
        {"John", 42},
        {"Michael", 17},
        {"Jenny", 26},
    }
    
    sort.Sort(ByAge(people))
    fmt.Println("排序后:", people)
}
```

3. 多字段可编程排序：
```go
// 定义基础类型
type Planet struct {
    name     string
    mass     float64
    distance float64
}

// 定义排序函数类型
type By func(p1, p2 *Planet) bool

// 实现Sort方法
func (by By) Sort(planets []Planet) {
    ps := &planetSorter{
        planets: planets,
        by:      by,
    }
    sort.Sort(ps)
}

// 实现sort.Interface
type planetSorter struct {
    planets []Planet
    by      func(p1, p2 *Planet) bool
}

func (s *planetSorter) Len() int { return len(s.planets) }
func (s *planetSorter) Swap(i, j int) { s.planets[i], s.planets[j] = s.planets[j], s.planets[i] }
func (s *planetSorter) Less(i, j int) bool { return s.by(&s.planets[i], &s.planets[j]) }

func main() {
    planets := []Planet{
        {"Mercury", 0.055, 0.4},
        {"Venus", 0.815, 0.7},
        {"Earth", 1.0, 1.0},
        {"Mars", 0.107, 1.5},
    }

    // 定义不同的排序规则
    name := func(p1, p2 *Planet) bool {
        return p1.name < p2.name
    }
    mass := func(p1, p2 *Planet) bool {
        return p1.mass < p2.mass
    }
    distance := func(p1, p2 *Planet) bool {
        return p1.distance < p2.distance
    }
    
    // 使用不同规则排序
    By(name).Sort(planets)
    fmt.Println("按名称排序:", planets)
    
    By(mass).Sort(planets)
    fmt.Println("按质量排序:", planets)
    
    By(distance).Sort(planets)
    fmt.Println("按距离排序:", planets)
}
```

4. 使用二分查找：
```go
func main() {
    numbers := []int{1, 3, 6, 8, 10, 15, 21, 28}
    
    // 查找大于等于13的第一个数的位置
    x := 13
    i := sort.Search(len(numbers), func(i int) bool {
        return numbers[i] >= x
    })
    
    if i < len(numbers) {
        fmt.Printf("找到最小的大于等于%d的数：%d\n", x, numbers[i])
    }
}
```

### 性能特征

1. 时间复杂度：
   - 一般排序：O(n log n)
   - 稳定排序：O(n log n)
   - 二分查找：O(log n)

2. 空间复杂度：
   - `Sort`：O(log n)
   - `Stable`：O(n)

### 使用建议

1. 优先使用 `sort.Slice` 和 `sort.SliceStable`：
   - 代码更简洁
   - 无需定义新类型
   - 可以直接使用闭包访问外部变量

2. 在以下情况下实现 `sort.Interface`：
   - 需要频繁复用的排序逻辑
   - 需要在包级别提供排序功能
   - 需要更好的代码组织和封装

3. 使用 `sort.Stable` 当：
   - 需要保持相等元素的原始顺序
   - 排序结果需要稳定性保证

4. 高级排序技巧：
   - 使用 `sort.Reverse` 实现降序排序
   - 实现多字段排序时考虑使用可编程排序模式
   - 对于已排序的数据，使用 `sort.Search` 进行高效查找

## container包

Go语言的`container`包提供了三个通用的容器数据结构实现：

- `container/heap`: 堆实现
- `container/list`: 双向链表实现
- `container/ring`: 循环链表实现

### container/heap包

`heap`包提供了堆（优先队列）的实现。堆是一个树形数据结构，其中每个父节点的值都小于或等于其子节点的值（最小堆）或大于或等于其子节点的值（最大堆）。

#### 接口和方法

```go
// heap.Interface 接口定义了堆操作所需的方法
type Interface interface {
    sort.Interface           // 继承 Len()、Less(i, j int)、Swap(i, j int)
    Push(x any)             // 添加x到末尾
    Pop() any               // 移除并返回最后一个元素
}

// 包级函数
func Init(h Interface)      // 将数据初始化为一个堆
func Push(h Interface, x any) // 将元素x压入堆
func Pop(h Interface) any   // 弹出并返回堆顶元素
func Remove(h Interface, i int) any // 移除索引i处的元素
func Fix(h Interface, i int)  // 重新建立索引i处元素的堆排序
```

#### 使用示例

1. 基本整数最小堆：
```go
package main

import (
    "container/heap"
    "fmt"
)

// IntHeap 是一个由整数组成的最小堆
type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *IntHeap) Push(x any) {
    *h = append(*h, x.(int))
}

func (h *IntHeap) Pop() any {
    old := *h
    n := len(old)
    x := old[n-1]
    *h = old[0 : n-1]
    return x
}

func main() {
    h := &IntHeap{2, 1, 5}
    heap.Init(h)

    heap.Push(h, 3)
    fmt.Printf("最小值: %d\n", (*h)[0])

    for h.Len() > 0 {
        fmt.Printf("%d ", heap.Pop(h))
    }
}
```

2. 优先队列实现：
```go
// Item 表示优先队列中的一个元素
type Item struct {
    value    string // 元素的值
    priority int    // 元素的优先级
    index    int    // 元素在堆中的索引
}

// PriorityQueue 实现了 heap.Interface 接口
type PriorityQueue []*Item

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {
    return pq[i].priority < pq[j].priority
}

func (pq PriorityQueue) Swap(i, j int) {
    pq[i], pq[j] = pq[j], pq[i]
    pq[i].index = i
    pq[j].index = j
}

func (pq *PriorityQueue) Push(x any) {
    n := len(*pq)
    item := x.(*Item)
    item.index = n
    *pq = append(*pq, item)
}

func (pq *PriorityQueue) Pop() any {
    old := *pq
    n := len(old)
    item := old[n-1]
    old[n-1] = nil  // 避免内存泄漏
    item.index = -1 // 为了安全
    *pq = old[0 : n-1]
    return item
}

// 更新修改优先队列中的项
func (pq *PriorityQueue) update(item *Item, value string, priority int) {
    item.value = value
    item.priority = priority
    heap.Fix(pq, item.index)
}

func main() {
    // 创建一个优先队列并添加一些项
    items := map[string]int{
        "任务1": 3,
        "任务2": 1,
        "任务3": 4,
    }

    pq := make(PriorityQueue, len(items))
    i := 0
    for value, priority := range items {
        pq[i] = &Item{
            value:    value,
            priority: priority,
            index:    i,
        }
        i++
    }
    heap.Init(&pq)

    // 插入一个新元素
    item := &Item{
        value:    "任务4",
        priority: 2,
    }
    heap.Push(&pq, item)

    // 更新一个元素
    pq.update(item, "任务4-更新", 0)

    // 按优先级顺序取出所有元素
    for pq.Len() > 0 {
        item := heap.Pop(&pq).(*Item)
        fmt.Printf("%.2d:%s ", item.priority, item.value)
    }
}
```

3. 定时器实现示例：
```go
type Timer struct {
    expiry   time.Time
    callback func()
    index    int
}

type TimerHeap []*Timer

func (h TimerHeap) Len() int { return len(h) }
func (h TimerHeap) Less(i, j int) bool { return h[i].expiry.Before(h[j].expiry) }
func (h TimerHeap) Swap(i, j int) {
    h[i], h[j] = h[j], h[i]
    h[i].index = i
    h[j].index = j
}

func (h *TimerHeap) Push(x any) {
    n := len(*h)
    timer := x.(*Timer)
    timer.index = n
    *h = append(*h, timer)
}

func (h *TimerHeap) Pop() any {
    old := *h
    n := len(old)
    timer := old[n-1]
    old[n-1] = nil
    timer.index = -1
    *h = old[0 : n-1]
    return timer
}

func main() {
    th := &TimerHeap{}
    heap.Init(th)

    // 添加定时器
    now := time.Now()
    heap.Push(th, &Timer{
        expiry:   now.Add(2 * time.Second),
        callback: func() { fmt.Println("Timer 1 expired") },
    })
    heap.Push(th, &Timer{
        expiry:   now.Add(1 * time.Second),
        callback: func() { fmt.Println("Timer 2 expired") },
    })

    // 模拟定时器触发
    for th.Len() > 0 {
        timer := heap.Pop(th).(*Timer)
        fmt.Printf("Timer will expire at: %v\n", timer.expiry)
    }
}
```

#### 性能特征

1. 时间复杂度：
   - Push：O(log n)
   - Pop：O(log n)
   - Remove：O(log n)
   - Fix：O(log n)
   - Init：O(n)
   - Top（查看堆顶）：O(1)

2. 空间复杂度：
   - 存储：O(n)
   - 每个操作的额外空间：O(1)

#### 使用建议

1. 适用场景：
   - 优先队列实现
   - 任务调度系统
   - 事件定时器
   - 数据流中位数计算
   - Dijkstra最短路径算法
   - 合并多个有序序列

2. 最佳实践：
   - 优先使用 `heap` 包提供的函数而不是直接操作底层切片
   - 实现 `heap.Interface` 时注意维护元素的索引
   - 使用指针接收器来避免不必要的复制
   - 在 `Pop` 方法中将移除的元素置为 nil 以避免内存泄漏

3. 注意事项：
   - 堆的第一个元素（索引0）始终是最小值（最小堆）
   - 修改堆中元素后需要调用 `Fix` 来维护堆的性质
   - `Push` 和 `Pop` 方法操作的是切片的末尾元素
   - 确保正确实现 `Less` 方法以决定最小堆或最大堆

4. 替代方案：
   - 需要有序集合时考虑使用 `sort` 包
   - 需要快速查找时考虑使用 `map`
   - 需要并发安全的优先队列时考虑使用 channel
   - 需要持久化的优先队列时考虑使用数据库

### container/list包

`list`包实现了一个双向链表。双向链表中的每个节点都包含一个值和两个指针，分别指向前一个节点和后一个节点。

#### 结构和方法

`List` 结构体定义：
```go
type List struct {
    root Element  // 哨兵节点，root.next 指向第一个元素
    len  int     // 当前链表长度
}

type Element struct {
    next, prev *Element  // 下一个和前一个元素的指针
    list *List          // 元素所属的链表
    Value any           // 元素值
}

// 主要方法
func New() *List          // 创建一个新的链表
func (l *List) Init()     // 初始化或清空链表
func (l *List) Front() *Element  // 返回第一个元素
func (l *List) Back() *Element   // 返回最后一个元素
func (l *List) Len() int         // 返回链表长度
func (l *List) PushFront(v any)  // 在链表前端插入元素
func (l *List) PushBack(v any)    // 在链表后端插入元素
func (l *List) InsertBefore(v any, mark *Element) // 在指定元素前插入
func (l *List) InsertAfter(v any, mark *Element)  // 在指定元素后插入
func (l *List) PushFrontList(other *List)         // 在链表前端插入另一个链表
func (l *List) PushBackList(other *List)          // 在链表后端插入另一个链表
func (l *List) MoveToFront(e *Element)            // 将元素移到链表前端
func (l *List) MoveToBack(e *Element)             // 将元素移到链表后端
func (l *List) MoveBefore(e, mark *Element)       // 将元素移到指定元素之前
func (l *List) MoveAfter(e, mark *Element)        // 将元素移到指定元素之后
func (l *List) Remove(e *Element)                 // 移除指定元素
```

#### 使用示例

1. 基本操作示例：
```go
package main

import (
    "container/list"
    "fmt"
)

func main() {
    // 创建新链表
    l := list.New()
    
    // 在后面添加元素
    l.PushBack("first")
    l.PushBack("second")
    
    // 在前面添加元素
    l.PushFront("zero")
    
    // 遍历并打印
    for e := l.Front(); e != nil; e = e.Next() {
        fmt.Printf("%v ", e.Value)
    }
    // 输出: zero first second
}
```

2. 元素操作示例：
```go
func listOperations() {
    l := list.New()
    
    // 添加元素并保存引用
    e4 := l.PushBack(4)
    e1 := l.PushFront(1)
    
    // 在特定位置插入
    l.InsertBefore(3, e4)  // 在4前插入3
    l.InsertAfter(2, e1)   // 在1后插入2
    
    // 移动元素
    e := l.Front()
    l.MoveToBack(e)  // 将第一个元素移到末尾
    
    // 删除元素
    l.Remove(e4)
}
```

3. 实现LRU缓存示例：
```go
type LRUCache struct {
    capacity int
    cache    map[string]*list.Element
    list     *list.List
}

func NewLRUCache(capacity int) *LRUCache {
    return &LRUCache{
        capacity: capacity,
        cache:    make(map[string]*list.Element),
        list:     list.New(),
    }
}

func (c *LRUCache) Get(key string) (string, bool) {
    if elem, ok := c.cache[key]; ok {
        c.list.MoveToFront(elem)  // 最近访问的移到前面
        return elem.Value.(string), true
    }
    return "", false
}

func (c *LRUCache) Put(key, value string) {
    if elem, ok := c.cache[key]; ok {
        c.list.MoveToFront(elem)
        elem.Value = value
        return
    }
    
    if c.list.Len() >= c.capacity {
        // 删除最久未使用的元素
        back := c.list.Back()
        delete(c.cache, back.Value.(string))
        c.list.Remove(back)
    }
    
    // 添加新元素
    elem := c.list.PushFront(value)
    c.cache[key] = elem
}
```

#### 性能特征

1. 时间复杂度：
   - 插入/删除：O(1)
   - 查找：O(n)
   - 访问头尾元素：O(1)

2. 空间复杂度：
   - 每个节点需要额外的前后指针存储空间
   - 总体空间复杂度：O(n)

#### 适用场景

1. LRU（最近最少使用）缓存
2. 任务队列
3. 历史记录管理
4. 撤销/重做功能实现
5. 需要频繁插入删除的场景
6. 需要双向遍历的场景

#### 使用建议

1. 当需要频繁的插入、删除操作时，优先使用 `list` 而不是切片
2. 如果主要是随机访问操作，建议使用切片而不是链表
3. 注意保存 `Element` 指针以便快速操作特定元素
4. 使用 `Remove` 方法删除元素时要确保元素确实在链表中

### container/ring包

`ring`包实现了环形链表的操作。环形链表是一种特殊的链表，其中最后一个元素指向第一个元素，形成一个环。

#### 结构和方法

```go
// Ring 是环形链表的一个元素，也代表整个环
type Ring struct {
    next, prev *Ring
    Value      any    // 用于存储元素值
}

// 主要方法
func New(n int) *Ring                     // 创建一个长度为n的环
func (r *Ring) Do(f func(any))           // 对环中的每个元素执行函数f
func (r *Ring) Len() int                 // 返回环的长度
func (r *Ring) Link(s *Ring) *Ring       // 将两个环连接在一起
func (r *Ring) Move(n int) *Ring         // 移动n个位置（n可以是负数）
func (r *Ring) Next() *Ring              // 返回下一个元素
func (r *Ring) Prev() *Ring              // 返回前一个元素
func (r *Ring) Unlink(n int) *Ring       // 从当前元素开始移除n个元素
```

#### 使用示例

1. 创建和遍历环：
```go
package main

import (
    "container/ring"
    "fmt"
)

func main() {
    // 创建一个长度为5的环
    r := ring.New(5)

    // 初始化环的值
    for i := 0; i < r.Len(); i++ {
        r.Value = i
        r = r.Next()
    }

    // 使用Do方法遍历环
    r.Do(func(p any) {
        fmt.Printf("%d ", p)
    })
    fmt.Println() // 输出: 0 1 2 3 4
}
```

2. 环的连接和分割：
```go
func main() {
    // 创建两个环
    r1 := ring.New(3)
    r2 := ring.New(2)

    // 初始化第一个环
    for i := 0; i < r1.Len(); i++ {
        r1.Value = fmt.Sprintf("r1-%d", i)
        r1 = r1.Next()
    }

    // 初始化第二个环
    for i := 0; i < r2.Len(); i++ {
        r2.Value = fmt.Sprintf("r2-%d", i)
        r2 = r2.Next()
    }

    // 连接两个环
    r3 := r1.Link(r2)

    // 遍历新环
    r3.Do(func(p any) {
        fmt.Printf("%s ", p)
    })
    fmt.Println() // 输出: r1-0 r1-1 r1-2 r2-0 r2-1

    // 分割环
    r4 := r3.Unlink(2)

    fmt.Print("第一部分: ")
    r3.Do(func(p any) {
        fmt.Printf("%s ", p)
    })
    fmt.Println()

    fmt.Print("第二部分: ")
    r4.Do(func(p any) {
        fmt.Printf("%s ", p)
    })
    fmt.Println()
}
```

3. 环的移动操作：
```go
func main() {
    // 创建环并初始化
    r := ring.New(5)
    for i := 0; i < r.Len(); i++ {
        r.Value = i
        r = r.Next()
    }

    // 向前移动2个位置
    r = r.Move(2)
    fmt.Printf("当前值: %d\n", r.Value)

    // 向后移动1个位置
    r = r.Move(-1)
    fmt.Printf("当前值: %d\n", r.Value)

    // 使用Next()和Prev()
    fmt.Printf("下一个值: %d\n", r.Next().Value)
    fmt.Printf("前一个值: %d\n", r.Prev().Value)
}
```

4. 实现循环缓冲区：
```go
type CircularBuffer struct {
    *ring.Ring
    size int
}

func NewCircularBuffer(size int) *CircularBuffer {
    return &CircularBuffer{
        Ring: ring.New(size),
        size: size,
    }
}

func (c *CircularBuffer) Add(value any) {
    c.Value = value
    c.Ring = c.Next()
}

func (c *CircularBuffer) GetAll() []any {
    values := make([]any, 0, c.size)
    c.Do(func(p any) {
        if p != nil {
            values = append(values, p)
        }
    })
    return values
}

func main() {
    // 创建一个大小为3的循环缓冲区
    buffer := NewCircularBuffer(3)

    // 添加4个元素（第4个会覆盖第1个）
    buffer.Add("A")
    buffer.Add("B")
    buffer.Add("C")
    buffer.Add("D")

    // 获取所有元素
    values := buffer.GetAll()
    fmt.Println(values) // 输出: [D B C] 或类似序列
}
```

#### 性能特征

1. 时间复杂度：
   - 创建环：O(n)
   - 遍历（Do）：O(n)
   - 移动（Move）：O(n) 对于大的n；O(1) 对于小的n
   - 连接（Link）：O(1)
   - 分割（Unlink）：O(n)

2. 空间复杂度：
   - 基本存储：O(n)
   - 每个元素额外需要两个指针（next和prev）

#### 适用场景

1. 循环缓冲区
2. 轮询调度算法
3. 循环列表处理
4. 固定大小的循环队列

#### 使用建议

1. 适用场景：
   - 循环缓冲区实现
   - 轮询调度算法
   - 循环列表处理
   - 固定大小的循环队列

2. 最佳实践：
   - 使用 `Do` 方法进行安全遍历
   - 注意保持对环的起始位置的引用
   - 在修改环结构时要小心处理指针
   - 考虑使用辅助函数封装常见操作

3. 注意事项：
   - Ring的零值是一个长度为1的空环
   - Link和Unlink操作会改变环的结构
   - Move的参数可以是负数，表示反向移动
   - Value字段是any类型，使用时需要类型断言

4. 替代方案：
   - 需要动态大小时考虑使用切片
   - 需要并发安全时考虑使用channel
   - 需要快速随机访问时考虑使用数组
