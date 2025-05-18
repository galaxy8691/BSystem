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
		return;
	}
	
	public void CounterClockwiseState()
	{
		if ((int)Actor.Get("rotate_times") == 0)
		{
			ChangeState("Clockwise");
		}else{
			Actor.Call("rotate_counterclockwise_180");
		}
	}

	public void CounterClockwiseInit()
	{
		return;
	}
}
