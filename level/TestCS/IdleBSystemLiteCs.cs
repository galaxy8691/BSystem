using Godot;
using System;

public partial class IdleBSystemLiteCs : BSystemLiteCs
{


	protected override void InitCall()
	{
		InsertState("Idle", IdleState, IdleInit);
		InsertState("Move", MoveState, MoveInit);
	}

	public void IdleState()
	{
		var idle_animation_finished = (ThreeStateBool)GetBlackboard("idle_animation_finished");
		if (idle_animation_finished == ThreeStateBool.NOTSET)
		{
			Actor.Call("play_idle");
			SetBlackboard("idle_animation_finished", ThreeStateBool.FALSE);
		}
		else if (idle_animation_finished == ThreeStateBool.FALSE)
		{
			return;
		}
		else
		{
			GD.Print("tell idle animation finished");
			SetBlackboard("idle_animation_finished", ThreeStateBool.NOTSET);
		}
	}
	public void IdleInit()
	{	
		SetBlackboard("idle_animation_finished", ThreeStateBool.NOTSET);
	}
	public void MoveState()
	{
		Actor.Call("stop_animation");
		if ( (bool)Actor.Call("sprite_in_target_position"))
		{
			SetBlackboard("move_finished", ThreeStateBool.TRUE);
			ChangeState("Idle");
		}
		else
		{
			var move_finished = (ThreeStateBool)GetBlackboard("move_finished");
			if (move_finished == ThreeStateBool.NOTSET)
			{
				Actor.Call("sprite_move_to_target_position");
				SetBlackboard("move_finished", ThreeStateBool.FALSE);
			}
			else if (move_finished == ThreeStateBool.FALSE){
				Actor.Call("sprite_move_to_target_position");
			}
		}
	}
	public void MoveInit()
	{
		SetBlackboard("move_finished", ThreeStateBool.NOTSET);
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
