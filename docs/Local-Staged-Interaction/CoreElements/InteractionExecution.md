---
sidebar_position: 3
---

# Interaction Execution

**Interaction Executions** are intended for **cosmetic and visual feedback purposes**. They are used within `Conditioned Interaction Executions`, which are part of the `Stage Interaction Feedback Component`.

Each `Conditioned Interaction Execution` contains:
- A **Gameplay Tag Query**
- An associated **Interaction Execution** instanced object

This structure ensures that visual feedback is only triggered when relevant.

---

## 🔁 How It Works

Whenever the `Staged Interaction Component` updates—by adding or removing interaction stages—the system will automatically:

- Call `ExecuteInteractionExecutionBegin()` on executions that **match** the current tag state.
- Call `ExecuteInteractionExecutionEnd()` on executions that **no longer match**.

This allows developers and designers to easily manage visual responses to gameplay events without hard-coding them.

And since these functions are blueprintable, you can extend the system to do anything from activating particle effects to UI elements.

---

## 🔧 Functions to Override

To implement your own visual behaviors, override the following functions in your custom execution class:

```cpp
void ExecuteInteractionExecutionBegin(UStageInteractionFeedbackComponent* InInteractionComponent);
void ExecuteInteractionExecutionEnd(UStageInteractionFeedbackComponent* InInteractionComponent);
```
