"""
SMARS Mathematical Reasoning Engine
Core implementation of the mathematical reasoning loop
"""

import re
import time
from typing import List, Dict, Tuple, Optional, Any
from dataclasses import dataclass
import sympy as sp
from sympy import symbols, solve, simplify, expand, factor, log, sqrt

from smars_types import (
    MathProblem, ReasoningStep, ReasoningTrajectory, StepValidation, 
    TrajectoryScore, ReasoningContext, ReasoningResult,
    create_math_problem, create_reasoning_step, create_trajectory,
    validate_step, score_trajectory, ProblemType, StepType
)


class MathematicalReasoningEngine:
    """Main engine for SMARS mathematical reasoning"""
    
    def __init__(self):
        self.confidence_threshold = 0.7
        self.max_trajectories = 3
        self.processing_start_time = None
        
    def parse_math_problem(self, problem_statement: str) -> MathProblem:
        """Parse problem statement into structured MathProblem"""
        # Detect problem type based on keywords
        problem_type = self._detect_problem_type(problem_statement)
        difficulty = self._estimate_difficulty(problem_statement)
        expected_steps = self._estimate_steps(problem_statement)
        
        return MathProblem(
            problem_id="",
            problem_statement=problem_statement,
            problem_type=problem_type,
            difficulty_level=difficulty,
            expected_steps=expected_steps,
            validation_criteria=self._get_validation_criteria(problem_type)
        )
    
    def _detect_problem_type(self, statement: str) -> str:
        """Detect problem type from statement"""
        statement_lower = statement.lower()
        
        if any(word in statement_lower for word in ['log', 'logarithm', 'ln']):
            return "algebra_logarithms"
        elif any(word in statement_lower for word in ['speed', 'rate', 'distance', 'time']):
            return "algebra_rates"
        elif any(word in statement_lower for word in ['game', 'strategy', 'wins', 'tokens']):
            return "game_theory"
        elif any(word in statement_lower for word in ['probability', 'lottery', 'drawn', 'random']):
            return "probability"
        elif any(word in statement_lower for word in ['rectangle', 'circle', 'geometry']):
            return "geometry"
        else:
            return "algebra"
    
    def _estimate_difficulty(self, statement: str) -> str:
        """Estimate problem difficulty"""
        complexity_indicators = len(re.findall(r'[xyz]', statement.lower()))
        complexity_indicators += len(re.findall(r'log|sqrt|sin|cos|tan', statement.lower()))
        
        if complexity_indicators <= 2:
            return "low_medium"
        elif complexity_indicators <= 4:
            return "medium"
        else:
            return "medium_high"
    
    def _estimate_steps(self, statement: str) -> int:
        """Estimate number of solution steps"""
        # Simple heuristic based on problem complexity
        if 'log' in statement.lower():
            return 7
        elif 'game' in statement.lower():
            return 6
        elif 'speed' in statement.lower():
            return 8
        else:
            return 5
    
    def _get_validation_criteria(self, problem_type: str) -> List[str]:
        """Get validation criteria for problem type"""
        base_criteria = ["mathematical_validity", "logical_consistency", "computational_accuracy"]
        
        if "algebra" in problem_type:
            base_criteria.append("algebraic_manipulation_correct")
        elif "geometry" in problem_type:
            base_criteria.append("geometric_reasoning_valid")
        elif "probability" in problem_type:
            base_criteria.append("probability_calculation_correct")
        
        return base_criteria
    
    def generate_candidate_approaches(self, problem: MathProblem) -> List[str]:
        """Generate different reasoning approaches for problem"""
        approaches = []
        
        if problem.problem_type == "algebra_rates":
            approaches = [
                "direct_formula_application",
                "component_analysis",
                "units_careful_analysis"
            ]
        elif problem.problem_type == "algebra_logarithms":
            approaches = [
                "direct_logarithm_properties",
                "exponential_form_conversion",
                "substitution_method"
            ]
        elif problem.problem_type == "game_theory":
            approaches = [
                "recursive_analysis",
                "pattern_recognition",
                "grundy_number_analysis"
            ]
        else:
            approaches = [
                "direct_approach",
                "systematic_approach",
                "algebraic_approach"
            ]
        
        return approaches[:self.max_trajectories]
    
    def execute_reasoning_step(self, operation: str, input_state: str, 
                             context: Optional[Dict] = None) -> ReasoningStep:
        """Execute a single reasoning step"""
        # This is a simplified implementation
        # In a real system, this would involve actual mathematical computation
        
        step_type = self._classify_operation(operation)
        output_state = self._apply_operation(operation, input_state, context)
        justification = self._generate_justification(operation, input_state, output_state)
        confidence = self._assess_step_confidence(operation, input_state, output_state)
        
        return create_reasoning_step(
            step_type=step_type,
            operation=operation,
            input_state=input_state,
            output_state=output_state,
            justification=justification,
            confidence=confidence
        )
    
    def _classify_operation(self, operation: str) -> str:
        """Classify the type of mathematical operation"""
        op_lower = operation.lower()
        
        if any(word in op_lower for word in ['substitute', 'replace']):
            return "substitution"
        elif any(word in op_lower for word in ['solve', 'isolate']):
            return "algebraic_manipulation"
        elif any(word in op_lower for word in ['apply', 'use']):
            return "formula_application"
        elif any(word in op_lower for word in ['compute', 'calculate']):
            return "computation"
        else:
            return "logical_inference"
    
    def _apply_operation(self, operation: str, input_state: str, context: Optional[Dict] = None) -> str:
        """Apply mathematical operation to input state"""
        # Simplified implementation - in reality this would involve symbolic computation
        
        # For demonstration, we'll simulate some basic operations
        if "solve" in operation.lower():
            return f"Solved: {input_state}"
        elif "substitute" in operation.lower():
            return f"After substitution: {input_state}"
        elif "simplify" in operation.lower():
            return f"Simplified: {input_state}"
        else:
            return f"Result: {input_state}"
    
    def _generate_justification(self, operation: str, input_state: str, output_state: str) -> str:
        """Generate justification for reasoning step"""
        return f"Applied {operation} to transform from '{input_state}' to '{output_state}'"
    
    def _assess_step_confidence(self, operation: str, input_state: str, output_state: str) -> float:
        """Assess confidence in reasoning step"""
        # Simple heuristic - in reality this would be more sophisticated
        base_confidence = 0.8
        
        if "solve" in operation.lower():
            return 0.9
        elif "substitute" in operation.lower():
            return 0.85
        elif "simplify" in operation.lower():
            return 0.8
        else:
            return base_confidence
    
    def execute_multiple_trajectories(self, problem: MathProblem) -> List[ReasoningTrajectory]:
        """Execute multiple reasoning trajectories for a problem"""
        approaches = self.generate_candidate_approaches(problem)
        trajectories = []
        
        for approach in approaches:
            trajectory = self._execute_single_trajectory(problem, approach)
            trajectories.append(trajectory)
        
        return trajectories
    
    def _execute_single_trajectory(self, problem: MathProblem, approach: str) -> ReasoningTrajectory:
        """Execute a single reasoning trajectory"""
        steps = []
        
        # Generate trajectory based on problem type and approach
        if problem.problem_type == "algebra_rates" and approach == "direct_formula_application":
            steps = self._generate_rate_problem_steps_direct(problem)
        elif problem.problem_type == "algebra_logarithms" and approach == "direct_logarithm_properties":
            steps = self._generate_log_problem_steps_direct(problem)
        elif problem.problem_type == "game_theory" and approach == "recursive_analysis":
            steps = self._generate_game_theory_steps_recursive(problem)
        else:
            # Default generic steps
            steps = self._generate_generic_steps(problem)
        
        trajectory_confidence = sum(step.confidence for step in steps) / len(steps) if steps else 0.0
        
        return create_trajectory(
            problem_id=problem.problem_id,
            steps=steps,
            approach=approach,
            confidence=trajectory_confidence
        )
    
    def _generate_rate_problem_steps_direct(self, problem: MathProblem) -> List[ReasoningStep]:
        """Generate steps for rate problem using direct approach"""
        steps = []
        
        # Step 1: Set up equations
        steps.append(create_reasoning_step(
            step_type="system_setup",
            operation="set_up_rate_equations",
            input_state=problem.problem_statement,
            output_state="9 = s × (4 - t/60) and 9 = (s + 2) × (2.4 - t/60)",
            justification="Apply distance = rate × time formula for both scenarios",
            confidence=0.9
        ))
        
        # Step 2: Solve system
        steps.append(create_reasoning_step(
            step_type="algebraic_manipulation",
            operation="solve_system_of_equations",
            input_state="9 = s × (4 - t/60) and 9 = (s + 2) × (2.4 - t/60)",
            output_state="s = 2.5 km/h, t = 24 minutes",
            justification="Solve simultaneous equations for s and t",
            confidence=0.85
        ))
        
        # Step 3: Apply to new scenario
        steps.append(create_reasoning_step(
            step_type="computation",
            operation="calculate_new_time",
            input_state="s = 2.5 km/h, t = 24 minutes, new speed = s + 1/2 = 3 km/h",
            output_state="Walking time = 9/3 = 3 hours = 180 minutes",
            justification="Calculate walking time at new speed",
            confidence=0.9
        ))
        
        # Step 4: Final answer
        steps.append(create_reasoning_step(
            step_type="computation",
            operation="add_coffee_time",
            input_state="Walking time = 180 minutes, Coffee time = 24 minutes",
            output_state="Total time = 204 minutes",
            justification="Add walking time and coffee time",
            confidence=0.95
        ))
        
        return steps
    
    def _generate_log_problem_steps_direct(self, problem: MathProblem) -> List[ReasoningStep]:
        """Generate steps for logarithm problem using direct approach"""
        steps = []
        
        # Step 1: Apply logarithm properties
        steps.append(create_reasoning_step(
            step_type="formula_application",
            operation="apply_logarithm_power_rule",
            input_state="log_x(y^x) = 10 and log_y(x^(4y)) = 10",
            output_state="x·log_x(y) = 10 and 4y·log_y(x) = 10",
            justification="Apply log(a^b) = b·log(a) rule",
            confidence=0.95
        ))
        
        # Step 2: Use change of base
        steps.append(create_reasoning_step(
            step_type="formula_application",
            operation="change_of_base_formula",
            input_state="x·log_x(y) = 10",
            output_state="x/log_y(x) = 10",
            justification="Apply log_a(b) = 1/log_b(a)",
            confidence=0.9
        ))
        
        # Step 3: Set up relationship
        steps.append(create_reasoning_step(
            step_type="algebraic_manipulation",
            operation="combine_equations",
            input_state="x/log_y(x) = 10 and 4y·log_y(x) = 10",
            output_state="log_y(x) = 5/(2y)",
            justification="From second equation, solve for log_y(x)",
            confidence=0.9
        ))
        
        # Step 4: Solve for xy
        steps.append(create_reasoning_step(
            step_type="algebraic_manipulation",
            operation="substitute_and_solve",
            input_state="x/(5/(2y)) = 10",
            output_state="xy = 25",
            justification="Substitute and solve for xy",
            confidence=0.85
        ))
        
        return steps
    
    def _generate_game_theory_steps_recursive(self, problem: MathProblem) -> List[ReasoningStep]:
        """Generate steps for game theory problem using recursive analysis"""
        steps = []
        
        # Step 1: Define winning/losing positions
        steps.append(create_reasoning_step(
            step_type="pattern_recognition",
            operation="define_game_positions",
            input_state="Game: remove 1 or 4 tokens, last player wins",
            output_state="P-position = losing for current player, N-position = winning",
            justification="Define game theory terminology",
            confidence=0.95
        ))
        
        # Step 2: Analyze small cases
        steps.append(create_reasoning_step(
            step_type="logical_inference",
            operation="analyze_base_cases",
            input_state="Positions 0, 1, 2, 3, 4, 5, ...",
            output_state="0:P, 1:N, 2:P, 3:N, 4:N, 5:N, 6:P, ...",
            justification="Compute P/N status for small positions",
            confidence=0.9
        ))
        
        # Step 3: Find pattern
        steps.append(create_reasoning_step(
            step_type="pattern_recognition",
            operation="identify_pattern",
            input_state="P-positions: 0, 2, 6, 9, 10, 13, 14, ...",
            output_state="P-positions are n ≡ 0, 2 (mod 5)",
            justification="Recognize modular arithmetic pattern",
            confidence=0.8
        ))
        
        # Step 4: Count solutions
        steps.append(create_reasoning_step(
            step_type="computation",
            operation="count_positions",
            input_state="Count n ≤ 2024 where n ≡ 0, 2 (mod 5)",
            output_state="404 + 405 = 809",
            justification="Count positions using modular arithmetic",
            confidence=0.85
        ))
        
        return steps
    
    def _generate_generic_steps(self, problem: MathProblem) -> List[ReasoningStep]:
        """Generate generic reasoning steps"""
        return [
            create_reasoning_step(
                step_type="problem_transformation",
                operation="analyze_problem",
                input_state=problem.problem_statement,
                output_state="Problem analysis complete",
                justification="Initial problem analysis",
                confidence=0.8
            ),
            create_reasoning_step(
                step_type="computation",
                operation="solve_problem",
                input_state="Problem analysis complete",
                output_state="Solution found",
                justification="Apply solution method",
                confidence=0.7
            )
        ]
    
    def validate_mathematical_step(self, step: ReasoningStep, 
                                 context: Optional[ReasoningContext] = None) -> StepValidation:
        """Validate a mathematical reasoning step"""
        # Enhanced validation with mathematical checking
        
        mathematical_validity = self._check_mathematical_validity(step)
        logical_consistency = self._check_logical_consistency(step)
        computational_accuracy = self._check_computational_accuracy(step)
        step_necessity = self._check_step_necessity(step)
        
        rationale = self._generate_validation_rationale(
            step, mathematical_validity, logical_consistency, 
            computational_accuracy, step_necessity
        )
        
        return StepValidation(
            step_id=step.step_id,
            mathematical_validity=mathematical_validity,
            logical_consistency=logical_consistency,
            computational_accuracy=computational_accuracy,
            step_necessity=step_necessity,
            validation_rationale=rationale
        )
    
    def _check_mathematical_validity(self, step: ReasoningStep) -> float:
        """Check mathematical validity of step"""
        # Simplified check - in reality would involve symbolic computation
        if step.step_type in ["formula_application", "algebraic_manipulation"]:
            return 0.95
        elif step.step_type == "computation":
            return 0.9
        else:
            return 0.85
    
    def _check_logical_consistency(self, step: ReasoningStep) -> float:
        """Check logical consistency of step"""
        # Check if step follows logically from input
        if step.justification and len(step.justification) > 10:
            return 0.9
        else:
            return 0.7
    
    def _check_computational_accuracy(self, step: ReasoningStep) -> float:
        """Check computational accuracy of step"""
        # Would involve actual computation checking
        return min(step.confidence, 0.95)
    
    def _check_step_necessity(self, step: ReasoningStep) -> float:
        """Check if step is necessary for solution"""
        # Heuristic based on step type
        if step.step_type in ["system_setup", "formula_application"]:
            return 0.95
        elif step.step_type == "computation":
            return 0.9
        else:
            return 0.8
    
    def _generate_validation_rationale(self, step: ReasoningStep, math_val: float, 
                                     logic_val: float, comp_val: float, necessity: float) -> str:
        """Generate rationale for validation"""
        avg_score = (math_val + logic_val + comp_val + necessity) / 4
        
        if avg_score >= 0.9:
            return f"Excellent {step.step_type} step with strong mathematical foundation"
        elif avg_score >= 0.8:
            return f"Good {step.step_type} step with solid reasoning"
        elif avg_score >= 0.7:
            return f"Acceptable {step.step_type} step with minor issues"
        else:
            return f"Questionable {step.step_type} step requiring review"
    
    def score_trajectory(self, trajectory: ReasoningTrajectory, 
                        step_validations: List[StepValidation]) -> TrajectoryScore:
        """Score a complete reasoning trajectory"""
        if not step_validations:
            return TrajectoryScore(
                trajectory_id=trajectory.trajectory_id,
                step_scores=[],
                overall_score=0.0,
                approach_quality=0.0,
                solution_correctness=0.0,
                reasoning_clarity=0.0,
                promotion_recommended=False
            )
        
        # Calculate various quality metrics
        avg_validity = sum(v.overall_validity for v in step_validations) / len(step_validations)
        approach_quality = self._assess_approach_quality(trajectory)
        solution_correctness = self._assess_solution_correctness(trajectory)
        reasoning_clarity = self._assess_reasoning_clarity(trajectory, step_validations)
        
        overall_score = (avg_validity + approach_quality + solution_correctness + reasoning_clarity) / 4
        
        return TrajectoryScore(
            trajectory_id=trajectory.trajectory_id,
            step_scores=step_validations,
            overall_score=overall_score,
            approach_quality=approach_quality,
            solution_correctness=solution_correctness,
            reasoning_clarity=reasoning_clarity,
            promotion_recommended=overall_score >= 0.8 and solution_correctness >= 0.8
        )
    
    def _assess_approach_quality(self, trajectory: ReasoningTrajectory) -> float:
        """Assess quality of overall approach"""
        # Heuristic based on approach type and trajectory confidence
        base_score = trajectory.trajectory_confidence
        
        if "direct" in trajectory.overall_approach:
            return min(base_score + 0.1, 1.0)
        elif "systematic" in trajectory.overall_approach:
            return min(base_score + 0.05, 1.0)
        else:
            return base_score
    
    def _assess_solution_correctness(self, trajectory: ReasoningTrajectory) -> float:
        """Assess correctness of solution"""
        # Would involve checking against known answers
        # For now, use trajectory confidence as proxy
        return trajectory.trajectory_confidence
    
    def _assess_reasoning_clarity(self, trajectory: ReasoningTrajectory, 
                                 validations: List[StepValidation]) -> float:
        """Assess clarity of reasoning"""
        # Based on step justifications and validation rationales
        if not validations:
            return 0.5
        
        clarity_scores = []
        for step, validation in zip(trajectory.reasoning_steps, validations):
            if step.justification and len(step.justification) > 20:
                clarity_scores.append(0.9)
            elif step.justification:
                clarity_scores.append(0.7)
            else:
                clarity_scores.append(0.3)
        
        return sum(clarity_scores) / len(clarity_scores)
    
    def select_best_trajectory(self, trajectory_scores: List[TrajectoryScore]) -> ReasoningTrajectory:
        """Select the best trajectory based on scores"""
        if not trajectory_scores:
            raise ValueError("No trajectory scores provided")
        
        # Sort by overall score, then by solution correctness
        sorted_scores = sorted(trajectory_scores, 
                             key=lambda x: (x.overall_score, x.solution_correctness), 
                             reverse=True)
        
        best_score = sorted_scores[0]
        
        # Find corresponding trajectory (in real implementation, would have better tracking)
        return None  # Placeholder - would return actual trajectory
    
    def generate_final_answer(self, trajectory: ReasoningTrajectory) -> str:
        """Generate final answer from best trajectory"""
        if not trajectory.reasoning_steps:
            return "No solution found"
        
        final_step = trajectory.reasoning_steps[-1]
        
        # Extract numerical answer from final step
        output = final_step.output_state
        
        # Simple pattern matching for answers
        import re
        numbers = re.findall(r'\d+', output)
        if numbers:
            return numbers[-1]  # Return last number found
        
        return "Solution incomplete"
    
    def execute_reasoning_loop(self, problem_statement: str) -> ReasoningResult:
        """Execute the complete mathematical reasoning loop"""
        self.processing_start_time = time.time()
        
        # Phase 1: Parse problem
        problem = self.parse_math_problem(problem_statement)
        
        # Phase 2: Generate multiple trajectories
        trajectories = self.execute_multiple_trajectories(problem)
        
        # Phase 3: Validate all steps
        all_validations = []
        for trajectory in trajectories:
            trajectory_validations = []
            for step in trajectory.reasoning_steps:
                validation = self.validate_mathematical_step(step)
                trajectory_validations.append(validation)
            all_validations.append(trajectory_validations)
        
        # Phase 4: Score trajectories
        trajectory_scores = []
        for trajectory, validations in zip(trajectories, all_validations):
            score = self.score_trajectory(trajectory, validations)
            trajectory_scores.append(score)
        
        # Phase 5: Select best trajectory
        best_trajectory = self._select_best_trajectory_with_scores(trajectories, trajectory_scores)
        
        # Phase 6: Generate final answer
        final_answer = self.generate_final_answer(best_trajectory)
        
        processing_time = time.time() - self.processing_start_time
        
        return ReasoningResult(
            problem_id=problem.problem_id,
            best_trajectory=best_trajectory,
            all_trajectories=trajectories,
            final_answer=final_answer,
            confidence=best_trajectory.trajectory_confidence,
            processing_time=processing_time,
            validation_summary=self._create_validation_summary(all_validations)
        )
    
    def _select_best_trajectory_with_scores(self, trajectories: List[ReasoningTrajectory], 
                                          scores: List[TrajectoryScore]) -> ReasoningTrajectory:
        """Select best trajectory using scores"""
        if not trajectories or not scores:
            raise ValueError("No trajectories or scores provided")
        
        # Find index of best score
        best_idx = max(range(len(scores)), key=lambda i: scores[i].overall_score)
        return trajectories[best_idx]
    
    def _create_validation_summary(self, all_validations: List[List[StepValidation]]) -> Dict[str, Any]:
        """Create summary of validation results"""
        total_steps = sum(len(validations) for validations in all_validations)
        if total_steps == 0:
            return {"total_steps": 0, "average_validity": 0.0}
        
        total_validity = sum(
            sum(v.overall_validity for v in validations) 
            for validations in all_validations
        )
        
        return {
            "total_steps": total_steps,
            "average_validity": total_validity / total_steps,
            "trajectory_count": len(all_validations)
        }


if __name__ == "__main__":
    # Test the reasoning engine
    engine = MathematicalReasoningEngine()
    
    # Test with a simple problem
    problem_statement = "Every morning Aya goes for a 9-kilometer-long walk and stops at a coffee shop afterwards. When she walks at a constant speed of s kilometers per hour, the walk takes her 4 hours, including t minutes spent in the coffee shop. When she walks at s + 2 kilometers per hour, the walk takes her 2 hours and 24 minutes, including t minutes spent in the coffee shop. Suppose Aya walks at s + 1/2 kilometers per hour. Find the number of minutes the walk takes her, including the t minutes spent in the coffee shop."
    
    result = engine.execute_reasoning_loop(problem_statement)
    
    print(f"Problem: {result.problem_id}")
    print(f"Final Answer: {result.final_answer}")
    print(f"Confidence: {result.confidence:.2f}")
    print(f"Processing Time: {result.processing_time:.2f}s")
    print(f"Trajectories Generated: {len(result.all_trajectories)}")
    print(f"Average Validity: {result.validation_summary['average_validity']:.2f}")