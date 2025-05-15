# B System - 行为树系统

[English Documentation](README.MD)

B System是一个基于Godot引擎的行为树（Behavior Tree）实现，用于游戏AI和逻辑控制。该系统提供了一种结构化的方式来组织和管理游戏中角色或实体的行为逻辑。

## 系统特点

- **状态管理**：支持多个状态的管理和切换
- **黑板系统**：通过字典实现的共享数据存储，便于行为节点间的数据交换
- **组合节点**：包含Sequence（序列）和Selector（选择器）等基础组合节点
- **状态组合节点**：新增的StateComposite系列节点，专用于状态管理
- **可扩展性**：基于Godot的节点系统，易于扩展和自定义

## 核心设计理念

### 单一状态处理

每个BSystem在每一帧的`_physics_process`中只会处理一个状态。这是一个有意的设计决策，让行为树更加聚焦和高效。当前状态由`current_state`属性决定，只有匹配当前状态的组合节点会被执行。

### 多系统并行处理

如果游戏对象需要同时处理多个行为系统（如移动系统、视觉系统、战斗系统等），应该为每个行为系统创建独立的BSystem实例。例如：

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

这种设计反映了现实中的系统分离：移动系统和视觉系统本来就是两个独立的系统，它们可以并行工作且相对独立。通过使用多个BSystem，您可以：

1. 使每个系统专注于其核心功能
2. 允许系统并行运行，互不干扰
3. 简化每个系统的复杂度
4. 提高代码可维护性

在设计行为树前，应当仔细分析游戏对象的行为需求，将其划分为相对独立的系统，然后为每个系统创建单独的BSystem实例。

## 用户需要使用的核心组件

作为用户，您只需要了解和使用以下6个关键组件：

- **BSystem**：行为树的根节点，管理整个行为树的执行和状态，**必须设置actor和init_state**
- **BSequence**：按顺序执行子节点，直到遇到失败或全部成功
- **BSelector**：选择一个子节点执行，直到找到成功的节点
- **BStateSequence**：带状态的序列节点，只在特定状态下执行，**必须设置state属性**
- **BStateSelector**：带状态的选择器节点，只在特定状态下执行，**必须设置state属性**
- **BAction**：执行具体行为的叶节点，**必须实现tick方法**

其他类（如BNode、BComposite、BStateComposite等）都是系统内部实现，用户无需直接使用。

## 所有节点的通用方法

所有继承自BNode的节点（包括BSystem、BSequence、BSelector、BStateSequence、BStateSelector和BAction）都提供以下通用方法：

### 状态管理
- **set_current_state(state: String)**：从任何节点调用，可以切换系统当前状态
  ```gdscript
  # 从任何BNode子类中切换状态
  my_action.set_current_state("Combat")  # 会自动调用BSystem的system_change_state方法
  ```

### 黑板数据访问
- **set_blackboard(key: String, value: Variant)**：从任何节点设置黑板数据
  ```gdscript
  # 从任何BNode子类中设置黑板数据
  my_sequence.set_blackboard("target_found", true)
  ```

- **get_blackboard(key: String) -> Variant**：从任何节点获取黑板数据
  ```gdscript
  # 从任何BNode子类中获取黑板数据
  var health = my_action.get_blackboard("player_health")
  ```

这些方法使得您可以从行为树中的任何节点访问和修改系统状态和黑板数据，无需直接引用BSystem实例。

### 从外部调用系统方法

您可以从外部（游戏逻辑中）直接调用BSystem的方法来控制行为树：

#### 切换状态
```gdscript
# 从游戏逻辑中切换AI状态
func _on_player_detected():
    $Enemy/BSystem.system_change_state("Combat")  # 直接从外部切换AI状态

func _on_player_lost():
    $Enemy/BSystem.system_change_state("Search")  # 切换到搜索状态
```

#### 访问黑板数据
您也可以从外部直接访问和修改BSystem的黑板数据：

```gdscript
# 从外部设置黑板数据
func _on_item_picked_up(item):
    $Enemy/BSystem.blackboard["last_seen_item"] = item
    # 或使用提供的方法
    $Enemy/BSystem._set_system_blackboard("last_seen_item", item)

# 从外部获取黑板数据
func _process(delta):
    var target = $Enemy/BSystem.blackboard.get("current_target")
    # 或使用提供的方法
    var target = $Enemy/BSystem._get_system_blackboard("current_target")
    if target:
        update_ui_target_indicator(target)
```

这种灵活性使您可以根据游戏事件触发AI状态的变化或修改AI的数据，实现游戏逻辑与AI行为的紧密交互。

## 初始化BSystem

使用BSystem时，有两个必须设置的属性：

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

如果不设置actor或init_state，系统将无法正常工作，可能导致错误或行为树不执行。

## 多系统协作示例

以下示例展示了如何使用多个BSystem实现移动系统和视觉系统的并行处理：

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
    movement_system.system_change_state("Walking")
    vision_system.system_change_state("Scanning")
```

## 实现BAction

使用BAction时，**必须**定义`tick`方法，该方法是行为节点的核心，包含了具体的行为逻辑：

```gdscript
class_name MyAction extends BAction

# tick方法必须实现，这是行为节点的核心
# 参数:
#   actor: 执行行为的角色/对象
#   blackboard: 共享数据字典
# 返回值:
#   必须返回BType.ActionType枚举值之一
func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
    # 实现具体的行为逻辑
    
    # 根据行为执行情况返回对应状态:
    # 成功完成行为 -> SUCCESS
    # 执行失败 -> FAILURE
    # 正在执行中 -> RUNNING
    
    return BType.ActionType.SUCCESS
```

每个BAction的`tick`方法都应该返回以下三种状态之一：
- **SUCCESS**: 行为成功完成
- **FAILURE**: 行为执行失败
- **RUNNING**: 行为正在执行中，下一帧会继续执行

## 状态命名规则

使用BStateSequence和BStateSelector时，**必须**设置其state属性。state名称格式应为：
- 推荐使用 `"State_状态名"` 格式，例如 `"State_Patrol"`、`"State_Combat"`
- 系统内部会自动处理添加 `"State_"` 前缀的操作，所以使用 `system_change_state()` 方法时只需传入状态名部分（如 `"Patrol"` 而非 `"State_Patrol"`）

只有当系统当前状态与节点的state属性匹配时，该节点才会被执行。

## 状态切换时的初始化

当系统切换到新状态时，可以为BStateSequence和BStateSelector节点定义初始化行为。通过重写`_init_when_change_state`方法，可以在状态激活时执行特定的初始化代码：

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

系统会在调用`system_change_state`方法切换状态时，自动调用匹配状态节点的`_init_when_change_state`方法。

## 系统提供的枚举类型

B System提供了两种重要的枚举类型：

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

这两种枚举类型可以在创建自定义BAction时使用。

## 组合节点与状态组合节点的区别

普通组合节点（BSequence、BSelector）适用于通用的行为逻辑组合，而状态组合节点（BStateSequence、BStateSelector）则专门用于状态管理系统中，只有当系统处于特定状态时才会执行。这使得行为树可以根据不同状态切换不同的行为模式。

## 使用方法

1. 在Godot项目中添加B System节点
2. **设置行为树的actor（必须）**
3. **设置行为树的init_state（必须）**
4. 创建并配置行为节点
5. **为所有BStateSequence和BStateSelector节点设置state属性**
6. **如需在状态切换时执行初始化，重写节点的`_init_when_change_state`方法**
7. **为所有BAction节点实现`tick`方法**
8. 通过连接节点构建行为逻辑
9. 使用blackboard在节点间共享数据
10. 使用system_change_state方法切换不同状态
11. **如果需要并行处理多个行为系统，为每个系统创建独立的BSystem实例**

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
    func tick(actor, blackboard) -> BType.ActionType:
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
patrol_system.system_change_state("Combat")  # 将系统状态切换为"State_Combat"，并调用combat_selector的_init_when_change_state方法
```

## 使用通用方法的示例

以下示例展示了如何在行为节点内部使用通用方法：

```gdscript
class FindTargetAction extends BAction:
    func tick(actor, blackboard) -> BType.ActionType:
        var target = actor.find_nearest_enemy()
        if target:
            # 从行为节点中设置黑板数据
            set_blackboard("current_target", target)
            
            # 从行为节点中切换状态
            set_current_state("Combat")
            return BType.ActionType.SUCCESS
        else:
            return BType.ActionType.FAILURE
```

## 自定义行为节点示例

以下是几个自定义行为节点的示例，演示如何正确实现tick方法：

```gdscript
# 移动到指定位置的行为
class_name MoveToPositionAction extends BAction
func tick(actor: CharacterBody2D, blackboard: Dictionary) -> BType.ActionType:
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
func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
    var target = blackboard.get("combat_target")
    if not target or not is_instance_valid(target):
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

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
    if wait_timer <= 0:
        wait_timer = duration
        
    wait_timer -= get_process_delta_time()
    
    if wait_timer <= 0:
        return BType.ActionType.SUCCESS
    else:
        return BType.ActionType.RUNNING
```

## 许可

请参阅项目中的LICENSE文件了解许可信息。 