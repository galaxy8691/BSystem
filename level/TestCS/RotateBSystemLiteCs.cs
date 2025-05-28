using Godot;
using System;
using System.Collections.Generic;

public partial class RotateBSystemLiteCs : BSystemLiteCs
{

	public class ClockwiseState : PackedState
	{
		public ClockwiseState(Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard) : base("Clockwise", actor, change_state_fn, blackboard)
		{
			
		}

		public override void StateFn()
		{
			if ((int)GetActor().Get("rotate_times") >= 200)
			{
				ChangeState("CounterClockwise");
			}
			else
			{
				GetActor().Call("rotate_clockwise_180");
			}
		}

		public override void InitWhenChangeStateFn()
		{
		}
	}

	public class CounterClockwiseState : PackedState
	{
		public CounterClockwiseState(Node actor, Action<string> change_state_fn, Dictionary<string, object> blackboard) : base("CounterClockwise", actor, change_state_fn, blackboard)
		{
		}

		public override void StateFn()
		{
			if ((int)GetActor().Get("rotate_times") == 0)
			{
				ChangeState("Clockwise");
			}
			else
			{
				GetActor().Call("rotate_counterclockwise_180");
			}
		}
		public override void InitWhenChangeStateFn()
		{
		}
	}
	
	protected override void InitCall()
	{
		InsertState(new FnState("Clockwise", Actor, ChangeState, m_Blackboard, () => {
			if ((int)Actor.Get("rotate_times") >= 200)
			{
				ChangeState("CounterClockwise");
			}
			else
			{
				Actor.Call("rotate_clockwise_180");
			}
		}, () => {
		}));
		// InsertState(new ClockwiseState(Actor, ChangeState, m_Blackboard));
		InsertState(new CounterClockwiseState(Actor, ChangeState, m_Blackboard));
	}

}
