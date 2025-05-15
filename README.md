# B System - Behavior Tree System

[中文文档](README_CN.MD)

B System is a Behavior Tree implementation based on the Godot engine, designed for game AI and logic control. It provides a structured way to organize and manage the behavior logic of characters or entities in games.

## System Features

- **State Management**: Support for managing and switching between multiple states
- **Blackboard System**: Shared data storage implemented through dictionaries for easy data exchange between behavior nodes
- **Composite Nodes**: Includes basic composite nodes such as Sequence and Selector
- **State Composite Nodes**: New StateComposite series nodes specially designed for state management
- **Extensibility**: Based on Godot's node system, easy to extend and customize

## Core Design Philosophy

### Single State Processing

Each BSystem only processes one state per frame in `_physics_process`. This is an intentional design decision to make the behavior tree more focused and efficient. The current state is determined by the `current_state` property, and only composite nodes matching the current state will be executed.

### Multi-System Parallel Processing

If a game object needs to process multiple behavior systems simultaneously (such as movement system, vision system, combat system, etc.), separate BSystem instances should be created for each behavior system. For example:

```gdscript
# Create movement system
var movement_system = BSystem.new()
movement_system.actor = $Character
movement_system.init_state = "State_Walking"

# Create vision system
var vision_system = BSystem.new()
vision_system.actor = $Character
vision_system.init_state = "State_Scanning"

# Add to character
$Character.add_child(movement_system)
$Character.add_child(vision_system)
```

This design reflects the separation of systems in reality: movement and vision systems are two independent systems that can work in parallel and relatively independently. By using multiple BSystem instances, you can:

1. Make each system focused on its core functionality
2. Allow systems to run in parallel without interfering with each other
3. Simplify the complexity of each system
4. Improve code maintainability

Before designing behavior trees, you should carefully analyze the behavior requirements of game objects, divide them into relatively independent systems, and then create separate BSystem instances for each system.

## Core Components Users Need

As a user, you only need to understand and use the following 6 key components:

- **BSystem**: The root node of the behavior tree, manages the execution and state of the entire behavior tree, **must set actor and init_state**
- **BSequence**: Executes child nodes in sequence until encountering a failure or all succeed
- **BSelector**: Selects a child node to execute until finding a successful node
- **BStateSequence**: State sequence node, only executes in specific states, **must set state property**
- **BStateSelector**: State selector node, only executes in specific states, **must set state property**
- **BAction**: Leaf node that executes specific behaviors, **must implement the tick method**

Other classes (such as BNode, BComposite, BStateComposite, etc.) are internal implementations of the system and users don't need to use them directly.

## Common Methods for All Nodes

All nodes inheriting from BNode (including BSystem, BSequence, BSelector, BStateSequence, BStateSelector, and BAction) provide the following common methods:

### State Management
- **set_current_state(state: String)**: Call from any node to switch the system's current state
  ```gdscript
  # Switch state from any BNode subclass
  my_action.set_current_state("Combat")  # Automatically calls system_change_state method of BSystem
  ```

### Blackboard Data Access
- **set_blackboard(key: String, value: Variant)**: Set blackboard data from any node
  ```gdscript
  # Set blackboard data from any BNode subclass
  my_sequence.set_blackboard("target_found", true)
  ```

- **get_blackboard(key: String) -> Variant**: Get blackboard data from any node
  ```gdscript
  # Get blackboard data from any BNode subclass
  var health = my_action.get_blackboard("player_health")
  ```

These methods allow you to access and modify system states and blackboard data from any node in the behavior tree without directly referencing the BSystem instance.

### Calling System Methods from External Sources

You can call BSystem methods directly from external sources (game logic) to control the behavior tree:

#### Switching States
```gdscript
# Switch AI state from game logic
func _on_player_detected():
    $Enemy/BSystem.system_change_state("Combat")  # Directly switch AI state from external

func _on_player_lost():
    $Enemy/BSystem.system_change_state("Search")  # Switch to search state
```

#### Accessing Blackboard Data
You can also directly access and modify BSystem's blackboard data from external sources:

```gdscript
# Set blackboard data from external
func _on_item_picked_up(item):
    $Enemy/BSystem.blackboard["last_seen_item"] = item
    # Or use the provided method
    $Enemy/BSystem._set_system_blackboard("last_seen_item", item)

# Get blackboard data from external
func _process(delta):
    var target = $Enemy/BSystem.blackboard.get("current_target")
    # Or use the provided method
    var target = $Enemy/BSystem._get_system_blackboard("current_target")
    if target:
        update_ui_target_indicator(target)
```

This flexibility allows you to trigger changes in AI states or modify AI data based on game events, enabling tight interaction between game logic and AI behavior.

## Initializing BSystem

When using BSystem, there are two properties that must be set:

1. **actor**: Must be set, specifies the subject object that executes the behavior (such as character, enemy, etc.)
2. **init_state**: Must be set, specifies the initial state of the behavior tree

```gdscript
# Create BSystem instance
var b_system = BSystem.new()

# Set actor (required)
b_system.actor = $Enemy  # Can be any Node object

# Set initial state (required)
b_system.init_state = "State_Patrol"  # Name with "State_" prefix

# Optional: Set blackboard data
b_system.blackboard = {
    "patrol_points": [$Point1, $Point2, $Point3],
    "alert_distance": 100.0
}
```

If actor or init_state is not set, the system will not work properly, which may cause errors or prevent the behavior tree from executing.

## Multi-System Collaboration Example

The following example shows how to use multiple BSystem instances to implement parallel processing of movement and vision systems:

```gdscript
# Set up multiple behavior systems in character script
extends CharacterBody2D

func _ready():
    # Create and set up movement system
    var movement_system = BSystem.new()
    movement_system.actor = self
    movement_system.init_state = "State_Idle"
    movement_system.name = "MovementSystem"
    
    # Create and set up vision system
    var vision_system = BSystem.new()
    vision_system.actor = self
    vision_system.init_state = "State_LookAround"
    vision_system.name = "VisionSystem"
    
    # Add to character
    add_child(movement_system)
    add_child(vision_system)
    
    # Create state sequence for movement system
    var walk_sequence = BStateSequence.new()
    walk_sequence.state = "State_Walking"
    
    # Create state sequence for vision system
    var scan_sequence = BStateSequence.new()
    scan_sequence.state = "State_Scanning"
    
    # Add to respective systems
    movement_system.add_child(walk_sequence)
    vision_system.add_child(scan_sequence)
    
    # Can switch states of each system independently
    movement_system.system_change_state("Walking")
    vision_system.system_change_state("Scanning")
```

## Implementing BAction

When using BAction, you **must** define the `tick` method, which is the core of the behavior node and contains the specific behavior logic:

```gdscript
class_name MyAction extends BAction

# The tick method must be implemented, this is the core of the behavior node
# Parameters:
#   actor: The character/object that performs the behavior
#   blackboard: Shared data dictionary
# Return value:
#   Must return one of the BType.ActionType enum values
func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
    # Implement specific behavior logic
    
    # Return corresponding status based on behavior execution:
    # Successfully completed behavior -> SUCCESS
    # Execution failed -> FAILURE
    # Currently executing -> RUNNING
    
    return BType.ActionType.SUCCESS
```

Each BAction's `tick` method should return one of the following three states:
- **SUCCESS**: Behavior successfully completed
- **FAILURE**: Behavior execution failed
- **RUNNING**: Behavior is currently executing, will continue execution in the next frame

## State Naming Rules

When using BStateSequence and BStateSelector, you **must** set their state property. The state name format should be:
- Recommended to use the `"State_stateName"` format, such as `"State_Patrol"`, `"State_Combat"`
- The system will automatically handle adding the `"State_"` prefix, so when using the `system_change_state()` method, you only need to pass the state name part (such as `"Patrol"` instead of `"State_Patrol"`)

A node will only be executed when the current system state matches the node's state property.

## Initialization When Switching States

When the system switches to a new state, you can define initialization behavior for BStateSequence and BStateSelector nodes. By overriding the `_init_when_change_state` method, you can execute specific initialization code when the state is activated:

```gdscript
# Custom state sequence node with initialization
class_name MyPatrolSequence extends BStateSequence

# This method will be called when the state switches to this node's corresponding state
func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
    # Execute initialization logic when state changes
    blackboard["patrol_index"] = 0
    blackboard["is_patrolling"] = true
    print("Initializing patrol state")
```

The system will automatically call the `_init_when_change_state` method of the matching state node when the `system_change_state` method is called to switch states.

## Enum Types Provided by the System

B System provides two important enum types:

### ActionType
Status type of behavior node execution results:
- **SUCCESS**: Execution successful
- **FAILURE**: Execution failed
- **RUNNING**: Currently executing
- **NOTSET**: Status not set

### ThreeStateBool
Three-state boolean type:
- **TRUE**: True
- **FALSE**: False
- **NOTSET**: Status not set

These two enum types can be used when creating custom BAction.

## Difference Between Composite Nodes and State Composite Nodes

Regular composite nodes (BSequence, BSelector) are suitable for general behavior logic combinations, while state composite nodes (BStateSequence, BStateSelector) are specifically used in state management systems and will only execute when the system is in a specific state. This allows the behavior tree to switch between different behavior modes based on different states.

## Usage Method

1. Add B System node in Godot project
2. **Set the actor for the behavior tree (required)**
3. **Set the init_state for the behavior tree (required)**
4. Create and configure behavior nodes
5. **Set the state property for all BStateSequence and BStateSelector nodes**
6. **If initialization is needed when switching states, override the `_init_when_change_state` method of the node**
7. **Implement the `tick` method for all BAction nodes**
8. Build behavior logic by connecting nodes
9. Use blackboard to share data between nodes
10. Use system_change_state method to switch states
11. **If parallel processing of multiple behavior systems is needed, create separate BSystem instances for each system**

## Example

```gdscript
# Create a simple patrol behavior
var patrol_system = BSystem.new()
patrol_system.actor = $Enemy  # Must set actor
patrol_system.init_state = "State_Patrol"  # Must set initial state
patrol_system.blackboard = {"patrol_points": [point1, point2, point3]}  # Optional blackboard data

# Add patrol state sequence with initialization
class MyPatrolSequence extends BStateSequence:
    func _init_when_change_state(actor, blackboard):
        blackboard["current_point_index"] = 0
        print("Patrol state initialized")

var patrol_sequence = MyPatrolSequence.new()
patrol_sequence.state = "State_Patrol"  # State name must match system's current state to execute

# Add combat state selector with initialization
class MyCombatSelector extends BStateSelector:
    func _init_when_change_state(actor, blackboard):
        blackboard["combat_target"] = actor.find_nearest_enemy()
        blackboard["combat_started_time"] = Time.get_ticks_msec()
        print("Combat state initialized")

var combat_selector = MyCombatSelector.new()
combat_selector.state = "State_Combat"  # State name must match system's current state to execute

# Create a custom behavior node
class MoveToPointAction extends BAction:
    func tick(actor, blackboard) -> BType.ActionType:
        var points = blackboard["patrol_points"]
        var current_index = blackboard["current_point_index"]
        var target = points[current_index]
        
        var distance = actor.global_position.distance_to(target)
        if distance < 10:
            # Reached target point, move to next point
            blackboard["current_point_index"] = (current_index + 1) % points.size()
            return BType.ActionType.SUCCESS
            
        # Move towards target point
        var direction = (target - actor.global_position).normalized()
        actor.velocity = direction * actor.speed
        actor.move_and_slide()
        return BType.ActionType.RUNNING

var move_action = MoveToPointAction.new()
patrol_sequence.add_child(move_action)
patrol_system.add_child(patrol_sequence)
patrol_system.add_child(combat_selector)

# Switch state (only need to pass state name part, no need to include "State_" prefix)
patrol_system.system_change_state("Combat")  # Will switch system state to "State_Combat" and call combat_selector's _init_when_change_state method
```

## Example of Using Common Methods

The following example shows how to use common methods inside behavior nodes:

```gdscript
class FindTargetAction extends BAction:
    func tick(actor, blackboard) -> BType.ActionType:
        var target = actor.find_nearest_enemy()
        if target:
            # Set blackboard data from behavior node
            set_blackboard("current_target", target)
            
            # Switch state from behavior node
            set_current_state("Combat")
            return BType.ActionType.SUCCESS
        else:
            return BType.ActionType.FAILURE
```

## Custom Behavior Node Examples

Here are some examples of custom behavior nodes, demonstrating how to correctly implement the tick method:

```gdscript
# Move to specified position behavior
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

# Attack target behavior
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

# Wait for specified time behavior
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

## License

Please refer to the LICENSE file in the project for license information. 