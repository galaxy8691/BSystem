using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class BSystemLiteCs : Node
{
	private Dictionary<string, Action> state_fns = new Dictionary<string, Action>();
	private Dictionary<string, Action> init_when_change_state_fns = new Dictionary<string, Action>();
	private Dictionary<string, object> blackboard = new Dictionary<string, object>();

	[Export]
	public Node Actor { get; set; }

	[Export]
	public string InitState { get; set; }

	public override void _Ready()
	{
		InitCall();
		ChangeState(InitState);
	}

	public void InsertState(string state, Action fn, Action init_fn)
	{
		state_fns[state] = fn;
		init_when_change_state_fns[state] = init_fn;
	}

	protected virtual void InitCall()
	{
	}

	public void ChangeState(string state)
	{
		blackboard["current_state"] = state;
		Action init_when_change_state_fn = init_when_change_state_fns[state];
		init_when_change_state_fn();
	}

	public override void _PhysicsProcess(double delta)
	{
		var current_state = blackboard["current_state"] as string;
		Action state_fn = state_fns[current_state];
		state_fn();
	}

}
