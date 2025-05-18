# B System - 行为树系统

[English Documentation](README.MD)

B System 是一个基于 Godot 引擎的行为树（Behavior Tree）实现，用于游戏 AI 和逻辑控制。该系统提供了一种结构化的方式来组织和管理游戏中角色或实体的行为逻辑。

## 系统特点

- **状态管理**：支持多个状态的管理和切换
- **黑板系统**：通过字典实现的共享数据存储，便于行为节点间的数据交换
- **组合节点**：包含 Sequence（序列）和 Selector（选择器）等基础组合节点
- **状态组合节点**：新增的 StateComposite 系列节点，专用于状态管理
- **可扩展性**：基于 Godot 的节点系统，易于扩展和自定义
- **轻量版本**：BSystemLite 提供更简单的状态管理，不需要完整的行为树结构

## 核心设计理念

### 单一状态处理

每个 BSystem 在每一帧的`_physics_process`中只会处理一个状态。这是一个有意的设计决策，让行为树更加聚焦和高效。当前状态由`current_state`属性决定，只有匹配当前状态的组合节点会被执行。

### 多系统并行处理

如果游戏对象需要同时处理多个行为系统（如移动系统、视觉系统、战斗系统等），应该为每个行为系统创建独立的 BSystem 实例。例如：

```gdscript
# 创建移动系统
var movement_system = BSystem.new()
movement_system.actor = $Character
movement_system.init_state = "State_Walking"

# 创建视觉系统
var vision_system = BSystem.new()
vision_system.actor = $Character
vision_system.init_state = "State_Scanning"

# 添加到角色
$Character.add_child(movement_system)
$Character.add_child(vision_system)
```

这种设计反映了现实中的系统分离：移动系统和视觉系统本来就是两个独立的系统，它们可以并行工作且相对独立。通过使用多个 BSystem，您可以：

1. 使每个系统专注于其核心功能
2. 允许系统并行运行，互不干扰
3. 简化每个系统的复杂度
4. 提高代码可维护性

在设计行为树前，应当仔细分析游戏对象的行为需求，将其划分为相对独立的系统，然后为每个系统创建单独的 BSystem 实例。

## 用户需要使用的核心组件

作为用户，您只需要了解和使用以下核心组件：

### 标准行为树（完整功能）

- **BSystem**：行为树的根节点，管理整个行为树的执行和状态，**必须设置 actor 和 init_state**
- **BSequence**：按顺序执行子节点，直到遇到失败或全部成功
- **BSelector**：选择一个子节点执行，直到找到成功的节点
- **BStateSequence**：带状态的序列节点，只在特定状态下执行，**必须设置 state 属性**
- **BStateSelector**：带状态的选择器节点，只在特定状态下执行，**必须设置 state 属性**
- **BAction**：执行具体行为的叶节点，**必须实现 tick 方法**

### 轻量级状态机

- **BSystemLite**：简化的状态机系统，用于更直接的状态控制，**必须设置 actor 和 init_state**

其他类（如 BNode、BComposite、BStateComposite 等）都是系统内部实现，用户无需直接使用。

## BSystemLite - 轻量级状态机

BSystemLite 提供了一种简化的状态管理方法，当您不需要完整的行为树结构时可以使用它。对于小规模的状态控制，它更高效，您可以直接编写状态逻辑。

### 使用 BSystemLite

要使用 BSystemLite，您需要：

1. 继承 BSystemLite 类
2. 重写`_init_call()`方法来注册您的状态
3. 定义状态函数和初始化函数
4. 使用`change_state()`方法添加状态转换

```gdscript
extends BSystemLite

func _init_call():
    # 注册状态及其处理函数和初始化函数
    insert_state("Idle", idle_state, idle_init)
    insert_state("Move", move_state, move_init)

    # 可选：定义状态之间的关系
    insert_state_last_type("Idle", "Move")

# Idle状态的处理函数
func idle_state():
    # 状态逻辑
    if some_condition:
        change_state("Move")

# Idle状态的初始化函数
func idle_init():
    # 进入Idle状态时的初始化逻辑
    blackboard["some_value"] = 0

# Move状态的处理函数
func move_state():
    # 状态逻辑
    if reached_destination:
        change_state("Idle")

# Move状态的初始化函数
func move_init():
    # 进入Move状态时的初始化逻辑
    blackboard["move_started"] = true
```

### BSystemLite 与完整 BSystem 的比较

| 功能     | BSystemLite          | BSystem          |
| -------- | -------------------- | ---------------- |
| 复杂度   | 低（直接状态函数）   | 高（树结构）     |
| 性能     | 对简单任务更高效     | 针对复杂行为优化 |
| 结构     | 扁平状态机           | 层次行为树       |
| 使用场景 | 简单的基于状态的控制 | 复杂的 AI 行为   |
| 设置     | 直接函数定义         | 节点层次结构构建 |

### 何时使用 BSystemLite

在以下情况下使用 BSystemLite：

- 您有一个只包含少量状态的简单状态机
- 您想直接控制状态逻辑
- 性能至关重要
- 您的行为不需要复杂的层次结构

## BSystemLiteCs - C#版本的轻量级状态机

BSystemLiteCs 提供了轻量级状态机的 C#实现。这使您可以使用 C#编写状态管理逻辑，同时保持与 GDScript 版本相同的设计原则。**BSystemLiteCs 的主要目的之一是通过利用 C#的静态类型和在计算密集型任务中更高效的执行来进一步提高性能**。

### BSystemLite、BSystemLiteCs 与完整 BSystem 的比较

| 功能     | BSystemLite          | BSystemLiteCs        | BSystem              |
| -------- | -------------------- | -------------------- | -------------------- |
| 复杂度   | 低（直接状态函数）   | 低（直接状态方法）   | 高（树结构）         |
| 性能     | 适合简单任务         | 适合计算密集型任务   | 针对复杂行为优化     |
| 结构     | 扁平状态机           | 扁平状态机           | 层次行为树           |
| 语言     | GDScript             | C#                   | GDScript             |
| 类型安全 | 动态类型             | 静态类型             | 动态类型             |
| 互操作性 | 与 GDScript 原生兼容 | 部分功能需要桥接方法 | 与 GDScript 原生兼容 |
| 使用场景 | 简单的基于状态的控制 | 性能关键的状态控制   | 复杂的 AI 行为       |
| 设置     | 直接函数定义         | 直接方法定义         | 节点层次结构构建     |

### 使用 BSystemLiteCs

要使用 BSystemLiteCs，您需要：

1. 继承 BSystemLiteCs 类
2. 重写`InitCall()`方法来注册您的状态
3. 定义状态方法和初始化方法
4. 使用`ChangeState()`方法添加状态转换

```csharp
using Godot;
using System;

public partial class MyBSystemLiteCs : BSystemLiteCs
{
    protected override void InitCall()
    {
        // 注册状态及其处理方法和初始化方法
        InsertState("Idle", IdleState, IdleInit);
        InsertState("Move", MoveState, MoveInit);
    }

    // Idle状态的处理方法
    public void IdleState()
    {
        // 状态逻辑
        if (SomeCondition())
        {
            ChangeState("Move");
        }
    }

    // Idle状态的初始化方法
    public void IdleInit()
    {
        // 进入Idle状态时的初始化逻辑
        SetBlackboard("some_value", 0);
    }

    // Move状态的处理方法
    public void MoveState()
    {
        // 状态逻辑
        if (ReachedDestination())
        {
            ChangeState("Idle");
        }
    }

    // Move状态的初始化方法
    public void MoveInit()
    {
        // 进入Move状态时的初始化逻辑
        SetBlackboard("move_started", true);
    }

    private bool SomeCondition()
    {
        // 实现
        return false;
    }

    private bool ReachedDestination()
    {
        // 实现
        return false;
    }
}
```

### C#中的黑板数据

C#实现提供了访问黑板数据的方法：

```csharp
// 设置黑板数据
SetBlackboard("key", value);

// 获取黑板数据（需要类型转换）
var value = (int)GetBlackboard("key");
var state = (ThreeStateBool)GetBlackboard("state_value");
```

### C#中的三态布尔值

BSystemLiteCs 包含三态布尔值的枚举：

```csharp
public enum ThreeStateBool
{
    TRUE = 0,
    FALSE = 1,
    NOTSET = 2
}
```

### 与 GDScript 的互操作性

在 GDScript 中使用 BSystemLiteCs 时，您需要注意以下几点：

1. GDScript 只能直接访问派生类中直接定义的方法
2. 从 BSystemLiteCs 继承的方法（如`SetBlackboard`和`GetBlackboard`）必须通过桥接方法暴露：

```csharp
// 桥接方法，用于暴露继承的功能
public void SetBoardValue(string key, object value)
{
    SetBlackboard(key, value);
}
```

然后在 GDScript 中：

```gdscript
# 现在可以从GDScript调用桥接方法
my_system.SetBoardValue("key", value)
```

### BSystemLiteCs 示例

以下是使用 BSystemLiteCs 为旋转对象实现的完整示例：

```csharp
using Godot;
using System;

public partial class RotateBSystemLiteCs : BSystemLiteCs
{
    protected override void InitCall()
    {
        InsertState("Clockwise", ClockwiseState, ClockwiseInit);
        InsertState("CounterClockwise", CounterClockwiseState, CounterClockwiseInit);
    }

    public void ClockwiseState()
    {
        if ((int)Actor.Get("rotate_times") >= 200)
        {
            ChangeState("CounterClockwise");
        }
        else
        {
            Actor.Call("rotate_clockwise_180");
        }
    }

    public void ClockwiseInit()
    {
        // 无需特殊初始化
    }

    public void CounterClockwiseState()
    {
        if ((int)Actor.Get("rotate_times") == 0)
        {
            ChangeState("Clockwise");
        }
        else
        {
            Actor.Call("rotate_counterclockwise_180");
        }
    }

    public void CounterClockwiseInit()
    {
        // 无需特殊初始化
    }
}
```

## 所有节点的通用方法

所有继承自 BNode 的节点（包括 BSystem、BSequence、BSelector、BStateSequence、BStateSelector 和 BAction）都提供以下通用方法：

### 状态管理

- **set_current_state(state: String)**：从任何节点调用，可以切换系统当前状态
  ```gdscript
  # 从任何BNode子类中切换状态
  my_action.set_current_state("Combat")  # 会自动调用BSystem的system_change_state方法
  ```

### 黑板数据访问

黑板是一个共享字典，可以直接从行为树中的任何节点访问：

```gdscript
# 从任何节点访问黑板
func tick(actor, blackboard) -> BType.ActionType:
    # 从黑板读取数据
    var health = blackboard["player_health"]

    # 向黑板写入数据
    blackboard["target_found"] = true

    return BType.ActionType.SUCCESS
```

黑板会在执行过程中自动传递给所有节点，使节点间的数据共享变得简单高效。

### 从外部调用系统方法

您可以从外部（游戏逻辑中）直接调用 BSystem 的方法来控制行为树：

#### 切换状态

```gdscript
# 从游戏逻辑中切换AI状态
func _on_player_detected():
    $Enemy/BSystem.change_state("Combat")  # 直接从外部切换AI状态

func _on_player_lost():
    $Enemy/BSystem.change_state("Search")  # 切换到搜索状态
```

#### 访问黑板数据

您也可以从外部直接访问和修改 BSystem 的黑板数据：

```gdscript
# 从外部设置黑板数据
func _on_item_picked_up(item):
    $Enemy/BSystem.blackboard["last_seen_item"] = item

# 从外部获取黑板数据
func _process(delta):
    var target = $Enemy/BSystem.blackboard.get("current_target")
    if target:
        update_ui_target_indicator(target)
```

这种灵活性使您可以根据游戏事件触发 AI 状态的变化或修改 AI 的数据，实现游戏逻辑与 AI 行为的紧密交互。

## 初始化 BSystem

使用 BSystem 时，有两个必须设置的属性：

1. **actor**: 必须设置，指定执行行为的主体对象（如角色、敌人等）
2. **init_state**: 必须设置，指定行为树的初始状态

```gdscript
# 创建BSystem实例
var b_system = BSystem.new()

# 设置actor（必须）
b_system.actor = $Enemy  # 可以是任何Node对象

# 设置初始状态（必须）
b_system.init_state = "State_Patrol"  # 使用"State_"前缀命名

# 可选：设置黑板数据
b_system.blackboard = {
    "patrol_points": [$Point1, $Point2, $Point3],
    "alert_distance": 100.0
}
```

如果不设置 actor 或 init_state，系统将无法正常工作，可能导致错误或行为树不执行。

## BSystemLite 示例

以下是使用 BSystemLite 为旋转对象实现两个状态的完整示例：

```gdscript
extends BSystemLite

func _init_call():
    # 注册顺时针和逆时针状态
    insert_state("Clockwise", clockwise_state, clockwise_init)
    insert_state("CounterClockwise", counterclockwise_state, counterclockwise_init)

# 顺时针旋转状态
func clockwise_state():
    if actor.rotate_times >= 200:
        # 达到旋转限制时切换到逆时针
        change_state("CounterClockwise")
    else:
        # 继续顺时针旋转
        actor.rotate_clockwise_180()

# 顺时针状态初始化
func clockwise_init():
    # 无需特殊初始化
    pass

# 逆时针旋转状态
func counterclockwise_state():
    if actor.rotate_times == 0:
        # 旋转重置时切回顺时针
        change_state("Clockwise")
    else:
        # 继续逆时针旋转
        actor.rotate_counterclockwise_180()

# 逆时针状态初始化
func counterclockwise_init():
    # 无需特殊初始化
    pass
```

场景中的设置：

```gdscript
# 在场景设置中：
@onready var rotate_system = $RotateBSystemLite

func _ready():
    # actor和init_state应在检查器中设置
    # rotate_system.actor = self
    # rotate_system.init_state = "Clockwise"
    pass
```

## 多系统协作示例

以下示例展示了如何使用多个 BSystem 实现移动系统和视觉系统的并行处理：

```gdscript
# 在角色脚本中设置多个行为系统
extends CharacterBody2D

func _ready():
    # 创建并设置移动系统
    var movement_system = BSystem.new()
    movement_system.actor = self
    movement_system.init_state = "State_Idle"
    movement_system.name = "MovementSystem"

    # 创建并设置视觉系统
    var vision_system = BSystem.new()
    vision_system.actor = self
    vision_system.init_state = "State_LookAround"
    vision_system.name = "VisionSystem"

    # 添加到角色
    add_child(movement_system)
    add_child(vision_system)

    # 为移动系统创建状态序列
    var walk_sequence = BStateSequence.new()
    walk_sequence.state = "State_Walking"

    # 为视觉系统创建状态序列
    var scan_sequence = BStateSequence.new()
    scan_sequence.state = "State_Scanning"

    # 添加到相应系统
    movement_system.add_child(walk_sequence)
    vision_system.add_child(scan_sequence)

    # 可以单独切换每个系统的状态
    movement_system.change_state("Walking")
    vision_system.change_state("Scanning")
```

## 实现 BAction

使用 BAction 时，**必须**定义`tick`方法，该方法是行为节点的核心，包含了具体的行为逻辑。该方法现在包含一个`fn_change_state`参数用于改变状态：

```gdscript
class_name MyAction extends BAction

# tick方法必须实现，这是行为节点的核心
# 参数:
#   actor: 执行行为的角色/对象
#   blackboard: 共享数据字典
#   fn_change_state: 用于改变系统状态的可调用对象
# 返回值:
#   必须返回BType.ActionType枚举值之一
func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
    # 实现具体的行为逻辑

    # 在tick中改变状态的方法:
    if some_condition:
        fn_change_state.call("NewState")

    # 根据行为执行情况返回对应状态:
    # 成功完成行为 -> SUCCESS
    # 执行失败 -> FAILURE
    # 正在执行中 -> RUNNING

    return BType.ActionType.SUCCESS
```

每个 BAction 的`tick`方法都应该返回以下三种状态之一：

- **SUCCESS**: 行为成功完成
- **FAILURE**: 行为执行失败
- **RUNNING**: 行为正在执行中，下一帧会继续执行

## 状态命名规则

使用 BStateSequence 和 BStateSelector 时，**必须**设置其 state 属性。state 名称格式应为：

- 推荐使用 `"State_状态名"` 格式，例如 `"State_Patrol"`、`"State_Combat"`
- 系统内部会自动处理添加 `"State_"` 前缀的操作，所以使用 `change_state()` 方法时只需传入状态名部分（如 `"Patrol"` 而非 `"State_Patrol"`）

只有当系统当前状态与节点的 state 属性匹配时，该节点才会被执行。

## 状态切换时的初始化

当系统切换到新状态时，可以为 BStateSequence 和 BStateSelector 节点定义初始化行为。通过重写`_init_when_change_state`方法，可以在状态激活时执行特定的初始化代码：

```gdscript
# 自定义带初始化的状态序列节点
class_name MyPatrolSequence extends BStateSequence

# 当状态切换到本节点对应的状态时，此方法会被调用
func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
    # 执行状态切换时的初始化逻辑
    blackboard["patrol_index"] = 0
    blackboard["is_patrolling"] = true
    print("初始化巡逻状态")
```

系统会在调用`change_state`方法切换状态时，自动调用匹配状态节点的`_init_when_change_state`方法。

## 系统提供的枚举类型

B System 提供了两种重要的枚举类型：

### ActionType

行为节点执行结果的状态类型：

- **SUCCESS**：执行成功
- **FAILURE**：执行失败
- **RUNNING**：正在执行中
- **NOTSET**：未设置状态

### ThreeStateBool

三态布尔值类型：

- **TRUE**：真
- **FALSE**：假
- **NOTSET**：未设置状态

这两种枚举类型可以在创建自定义 BAction 时使用。

## 组合节点与状态组合节点的区别

普通组合节点（BSequence、BSelector）适用于通用的行为逻辑组合，而状态组合节点（BStateSequence、BStateSelector）则专门用于状态管理系统中，只有当系统处于特定状态时才会执行。这使得行为树可以根据不同状态切换不同的行为模式。

## 使用方法

1. 在 Godot 项目中添加 B System 节点
2. **设置行为树的 actor（必须）**
3. **设置行为树的 init_state（必须）**
4. 创建并配置行为节点
5. **为所有 BStateSequence 和 BStateSelector 节点设置 state 属性**
6. **如需在状态切换时执行初始化，重写节点的`_init_when_change_state`方法**
7. **为所有 BAction 节点实现带有正确签名的 tick 方法**
8. 通过连接节点构建行为逻辑
9. 使用 blackboard 在节点间共享数据
10. 使用 change_state 方法切换不同状态
11. **如果需要并行处理多个行为系统，为每个系统创建独立的 BSystem 实例**

## 示例

```gdscript
# 创建一个简单的巡逻行为
var patrol_system = BSystem.new()
patrol_system.actor = $Enemy  # 必须设置actor
patrol_system.init_state = "State_Patrol"  # 必须设置初始状态
patrol_system.blackboard = {"patrol_points": [point1, point2, point3]}  # 可选设置黑板数据

# 添加带初始化的巡逻状态序列
class MyPatrolSequence extends BStateSequence:
    func _init_when_change_state(actor, blackboard):
        blackboard["current_point_index"] = 0
        print("巡逻状态已初始化")

var patrol_sequence = MyPatrolSequence.new()
patrol_sequence.state = "State_Patrol"  # 状态名必须与系统当前状态匹配才会执行

# 添加带初始化的战斗状态选择器
class MyCombatSelector extends BStateSelector:
    func _init_when_change_state(actor, blackboard):
        blackboard["combat_target"] = actor.find_nearest_enemy()
        blackboard["combat_started_time"] = Time.get_ticks_msec()
        print("战斗状态已初始化")

var combat_selector = MyCombatSelector.new()
combat_selector.state = "State_Combat"  # 状态名必须与系统当前状态匹配才会执行

# 创建一个自定义行为节点
class MoveToPointAction extends BAction:
    func tick(actor, blackboard, fn_change_state) -> BType.ActionType:
        var points = blackboard["patrol_points"]
        var current_index = blackboard["current_point_index"]
        var target = points[current_index]

        var distance = actor.global_position.distance_to(target)
        if distance < 10:
            # 到达目标点，前往下一个点
            blackboard["current_point_index"] = (current_index + 1) % points.size()
            return BType.ActionType.SUCCESS

        # 向目标点移动
        var direction = (target - actor.global_position).normalized()
        actor.velocity = direction * actor.speed
        actor.move_and_slide()
        return BType.ActionType.RUNNING

var move_action = MoveToPointAction.new()
patrol_sequence.add_child(move_action)
patrol_system.add_child(patrol_sequence)
patrol_system.add_child(combat_selector)

# 切换状态（只需传入状态名部分，无需包含"State_"前缀）
patrol_system.change_state("Combat")  # 将系统状态切换为"State_Combat"，并调用combat_selector的_init_when_change_state方法
```

## 在动作节点中使用状态切换的示例

以下示例展示了如何在动作节点中使用 fn_change_state 参数来改变状态：

```gdscript
class FindTargetAction extends BAction:
    func tick(actor, blackboard, fn_change_state) -> BType.ActionType:
        var target = actor.find_nearest_enemy()
        if target:
            # 直接设置黑板数据
            blackboard["current_target"] = target

            # 使用提供的可调用对象切换状态
            fn_change_state.call("Combat")
            return BType.ActionType.SUCCESS
        else:
            return BType.ActionType.FAILURE
```

## 自定义行为节点示例

以下是几个自定义行为节点的示例，演示如何正确实现 tick 方法：

```gdscript
# 移动到指定位置的行为
class_name MoveToPositionAction extends BAction
func tick(actor: CharacterBody2D, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
    var target_position = blackboard.get("target_position")
    if not target_position:
        return BType.ActionType.FAILURE

    var direction = (target_position - actor.global_position).normalized()
    if actor.global_position.distance_to(target_position) < 10:
        return BType.ActionType.SUCCESS

    actor.velocity = direction * actor.speed
    actor.move_and_slide()
    return BType.ActionType.RUNNING

# 攻击目标的行为
class_name AttackTargetAction extends BAction
func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
    var target = blackboard.get("combat_target")
    if not target or not is_instance_valid(target):
        # 目标丢失，切换到搜索状态
        fn_change_state.call("Search")
        return BType.ActionType.FAILURE

    if actor.global_position.distance_to(target.global_position) > actor.attack_range:
        return BType.ActionType.FAILURE

    if not actor.can_attack():
        return BType.ActionType.RUNNING

    actor.attack(target)
    return BType.ActionType.SUCCESS

# 等待指定时间的行为
class_name WaitAction extends BAction
var wait_timer: float = 0
var duration: float = 2.0

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
    if wait_timer <= 0:
        wait_timer = duration

    wait_timer -= get_process_delta_time()

    if wait_timer <= 0:
        return BType.ActionType.SUCCESS
    else:
        return BType.ActionType.RUNNING
```

## 许可

请参阅项目中的 LICENSE 文件了解许可信息。
