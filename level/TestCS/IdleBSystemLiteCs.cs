using Godot;
using System;
using System.Collections.Generic;

public partial class IdleBSystemLiteCs : BSystemLiteCs
{

	public class IdleState : PackedState
	{
		public IdleState(Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard) : base("Idle", actor, change_state_fn, blackboard)
		{
		}

	
		public override void StateFn()
		{
			var idle_animation_finished = (ThreeStateBool)m_Blackboard["idle_animation_finished"];
		if (idle_animation_finished == ThreeStateBool.NOTSET)
		{
			GetActor().Call("play_idle");
			m_Blackboard["idle_animation_finished"] = ThreeStateBool.FALSE;
		}
		else if (idle_animation_finished == ThreeStateBool.FALSE)
		{
			return;
		}
		else
		{
			GD.Print("tell idle animation finished");
			m_Blackboard["idle_animation_finished"] = ThreeStateBool.NOTSET;
		}
		}
		public override void InitWhenChangeStateFn()
		{
			m_Blackboard["idle_animation_finished"] = ThreeStateBool.NOTSET;
		}
	}

	public class MoveState : PackedState
	{
		public MoveState(Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard) : base("Move", actor, change_state_fn, blackboard)
		{
		}
		public override void StateFn()
		{
			GetActor().Call("stop_animation");
			if ( (bool)GetActor().Call("sprite_in_target_position"))
			{
				m_Blackboard["move_finished"] = ThreeStateBool.TRUE;
				ChangeState("Idle");
			}
			else
			{
				var move_finished = (ThreeStateBool)m_Blackboard["move_finished"];
				if (move_finished == ThreeStateBool.NOTSET)
				{
					GetActor().Call("sprite_move_to_target_position");
					m_Blackboard["move_finished"] = ThreeStateBool.FALSE;
				}
				else if (move_finished == ThreeStateBool.FALSE){
					GetActor().Call("sprite_move_to_target_position");
				}
			}
		}
		public override void InitWhenChangeStateFn()
		{
			m_Blackboard["move_finished"] = ThreeStateBool.NOTSET;
		}
	}

	protected override void InitCall()
	{
		InsertState(new IdleState(Actor, ChangeState, m_Blackboard));
		InsertState(new MoveState(Actor, ChangeState, m_Blackboard));
	}




	public void SetAnimationFinished()
	{
		SetBlackboard("idle_animation_finished", ThreeStateBool.TRUE);
	}
	// public object GetBlackboard(string key)
	// {
	// 	return base.GetBlackboard(key);
	// }
}
