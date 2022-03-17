---
title: "Go 泛型使用与性能对比"
description: 不知道等了多久的泛型终于来了
date: 2022-03-17T11:42:12+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
- Go
- 泛型
categories:
- 笔记
---

2022年3月15号，Go 1.18版本正式发布，泛型也在这个版本中被支持。

下面简单的学习了下Go的泛型使用：

## 基本使用

首先从最常用的max函数来看。
假设我现在需要两个int类型的最大值，原先的Go写法是：

```go
package main

import "fmt"

func main() {
 fmt.Println(maxInt(32, 64))
}

func maxInt(a, b int) int {
 if a > b {
  return a
 }
 return b
}
```

这个时候我需要增加一个获取float64的最大值，那么我们就要新增一个函数叫`maxFloat64`：

```go
func maxFloat64(a, b float64) float64 {
 if a > b {
  return a
 }
 return b
}
```

每当我们需要对一种类型进行比较的时候，我们都需要重新编写一个函数，尽管他们的逻辑其实都是一样的，将来甚至还需要int8、int16、int32等等的类型。

当引入泛型之后，我们可以写成：

```go
package main

import (
 "fmt"
)

func main() {
 fmt.Println(max(1, 2))
 fmt.Println(max[int32](1, 2))
 fmt.Println(max(1.5, 2.3))
}

func max[T int | int8 | int16 | int32 | int64 | float32 | float64](a, b T) T {
 if a > b {
  return a
 }
 return b
}
```

当然，后面跟了一长串的int｜int8、、、这样实在有点费劲，如果我们之后需要增加一个min函数呢，岂不是又要把上面的这些抄一遍吗，所以这里还可以用interface提前定义下：

```go
package main

import (
 "fmt"
)

func main() {
 fmt.Println(max(1, 2))
 fmt.Println(max[int32](1, 2))
 fmt.Println(max(1.5, 2.3))

 fmt.Println(min(1, 2))
 fmt.Println(min[int32](1, 2))
 fmt.Println(min(1.5, 2.3))

}

type Number interface {
 int | int8 | int16 | int32 | int64 | float32 | float64
}

func max[T Number](a, b T) T {
 if a > b {
  return a
 }
 return b
}

func min[T Number](a, b T) T {
 if a < b {
  return a
 }
 return b
}
```

## 在结构体中使用泛型

除了函数声明中可以使用泛型，结构体中一样可以使用：

```go
package main

import (
 "fmt"
)

type Data[T comparable] struct {
 Message T
}

func (d Data[T]) Print() {
 fmt.Println(d.Message)
}

func main() {
 d := Data[int]{
  Message: 66,
 }
 d.Print()
}
```

这里有个类型：`comparable`

可以看看go的源码里面写的：

```go
// comparable is an interface that is implemented by all comparable types
// (booleans, numbers, strings, pointers, channels, arrays of comparable types,
// structs whose fields are all comparable types).
// The comparable interface may only be used as a type parameter constraint,
// not as the type of a variable.
type comparable interface{ comparable }
```

大概意思就是允许booleans, numbers, strings, pointers, channels, comparable类型组成的arrays以及所有字段都是由comparable类型组成的struct。

这里也有一个any类型：

```go
// any is an alias for interface{} and is equivalent to interface{} in all ways.
type any = interface{}
```

其实就是interface{}的别称。

## 与interface{}性能对比

在没有泛型的时候，我们想要通常使用interface{}和断言来模拟泛型操作，比如我们构建一个简单的KV内存缓存：

```go

type Message struct {
 message string
}

func NewStore() *Store {
 return &Store{
  data: make(map[string]interface{}),
 }
}

type Store struct {
 data map[string]interface{}
}

func (s *Store) Get(k string) (interface{}, bool) {
 d, ok := s.data[k]
 return d, ok
}
func (s *Store) Set(k string, v interface{}) {
 s.data[k] = v
}
func (s *Store) Del(k string) {
 delete(s.data, k)
}
```

这里我们定义的需要存储的类型为Message，
我们需要在内部使用一个map[string]interface{}来存放数据

对应的插入、查找以及删除操作为：

```go
 s.Set("test", &Message{message: "message"})
 d, _ := s.Get("test")
 _ = d.(Message)
 s.Del("test")
```

因为没有泛型，所以每次通过Get获取到的数据都需要进行一次断言，转换为我们期望的类型。

当有了泛型之后，一切都变得简单了，我们不在需要断言，代码编程：

```go

type TStore[K comparable, V any] struct {
 data map[K]V
}

func NewTStore[K comparable, V any]() *TStore[K, V] {
 return &TStore[K, V]{
  data: make(map[K]V),
 }
}

func (s *TStore[K, V]) Get(k K) (V, bool) {
 d, ok := s.data[k]
 return d, ok
}
func (s *TStore[K, V]) Set(k K, v V) {
 s.data[k] = v
}
func (s *TStore[K, V]) Del(k K) {
 delete(s.data, k)
}
```

这里用于存储数据的map变为通过泛型来实现，所以对应的操作简化为：

```go
 s.Set("test", Message{message: "message"})
 d, _ := s.Get("test")
 _ = d
 s.Del("test")
```

与使用interface{}方法实现的相比，泛型的版本可以直接使用Get到的数据，而不用执行断言。

下面我们可以跑下benchmark来看看两者的差别：

```shell
goos: linux
goarch: amd64
pkg: generics
cpu: AMD Ryzen 5 3400G with Radeon Vega Graphics
BenchmarkGenerice-8     32675426         35.01 ns/op        0 B/op        0 allocs/op
BenchmarkInterface-8    17569459         67.05 ns/op       16 B/op        1 allocs/op
PASS
coverage: 0.0% of statements
ok   generics 2.433s
```

interface {}实现的版本比泛型实现的版本的性能差一倍！

下面贴上测试的完整代码：

```go
package main

import (
 "testing"
)

type TStore[K comparable, V any] struct {
 data map[K]V
}

func NewTStore[K comparable, V any]() *TStore[K, V] {
 return &TStore[K, V]{
  data: make(map[K]V),
 }
}

func (s *TStore[K, V]) Get(k K) (V, bool) {
 d, ok := s.data[k]
 return d, ok
}
func (s *TStore[K, V]) Set(k K, v V) {
 s.data[k] = v
}
func (s *TStore[K, V]) Del(k K) {
 delete(s.data, k)
}

type Message struct {
 message string
}

func NewStore() *Store {
 return &Store{
  data: make(map[string]interface{}),
 }
}

type Store struct {
 data map[string]interface{}
}

func (s *Store) Get(k string) (interface{}, bool) {
 d, ok := s.data[k]
 return d, ok
}
func (s *Store) Set(k string, v interface{}) {
 s.data[k] = v
}
func (s *Store) Del(k string) {
 delete(s.data, k)
}

func testT(s *TStore[string, Message]) {
 s.Set("test", Message{message: "message"})
 d, _ := s.Get("test")
 _ = d
 s.Del("test")
}
func BenchmarkGenerice(b *testing.B) {
 t := NewTStore[string, Message]()
 for n := 0; n < b.N; n++ {
  testT(t) // run fib(30) b.N times
 }
}

func test(s *Store) {
 s.Set("test", Message{message: "message"})
 d, _ := s.Get("test")
 _ = d.(Message)
 s.Del("test")
}
func BenchmarkInterface(b *testing.B) {
 t := NewStore()
 for n := 0; n < b.N; n++ {
  test(t) // run fib(30) b.N times
 }
}

```

强烈推荐大家升级到新版Go，体验下泛型。
