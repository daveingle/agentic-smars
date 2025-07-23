# FAQ

### How are § plans symbolically executed?

  From impl/runtime.smars.md:

  ```(ƒ execute_plan ∷ PlanDefinition → PlanExecution)
    (ƒ execute_plan ∷ PlanDefinition → PlanExecution)
  
    (§ plan_execution
      steps:
        - initialize_execution_frame
        - validate_step_dependencies
        - execute_sequential_steps
        - maintain_execution_trace
        - validate_plan_postconditions
    )
  ```

  Plans are executed as sequential symbol resolution:
  1. Each step is an IDENTIFIER that must resolve in the symbol_table

  2. Steps execute in declaration order within the execution frame

  3. Each step can be another plan, maplet application, or atomic operation

  4. Execution maintains causal trace for debugging/validation

     

### Where do ⊨ contracts get validated?

Contracts validate at multiple execution points:

1. During Maplet Execution:

   ```
     (§ maplet_execution
       steps:
         - check_preconditions      # ⊨ requires: clauses
         - execute_function_logic
         - check_postconditions     # ⊨ ensures: clauses
     )
   ```

2. During Plan Execution
   ```
     (§ plan_execution
       steps:
         - validate_plan_postconditions  # Final contract check
     )
   ```

3. Continuous Monitoring

   ```
   (§ dynamic_validation
       steps:
         - monitor_execution_state
         - track_contract_compliance
         - validate_runtime_invariants
     )
   
   ```

Contracts are checked before, during, and after symbolic operations.



### Can ƒ be used to derive executability?

  Yes - ƒ maplets are the primary executability mechanism:

  1. Type-based Executability:
    `(ƒ function_name ∷ InputType → OutputType)`
    
    If InputType is satisfiable and OutputType is constructible, the maplet is executable
    2. Executability Derivation:

 ```  
 (ƒ derive_executability ∷ MapletSignature → ExecutabilityResult)
 
 (§ executability_analysis
  	steps:
      - validate_input_type_satisfiable
      - check_output_type_constructible
      - verify_implementation_exists
      - confirm_contract_fulfillable
  )
 ```

  3. Execution Decision Logic:

       - Plans reference maplets by identifier

       - Runtime resolves maplet signatures to determine if execution is possible

       - Maplets define the computational interface - if a step resolves to an executable maplet, the plan step is executable


  Therefore: ƒ maplets are both specification (signature) and executability predicate (can this computation be performed).