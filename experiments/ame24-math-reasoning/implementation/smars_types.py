"""
SMARS Mathematical Reasoning Types
Implementation of core SMARS types for mathematical reasoning system
"""

from dataclasses import dataclass
from typing import List, Dict, Optional, Any, Union
from enum import Enum
import uuid
import time


@dataclass
class MathProblem:
    """Core mathematical problem representation"""
    problem_id: str
    problem_statement: str
    problem_type: str
    difficulty_level: str
    expected_steps: int
    validation_criteria: List[str]
    
    def __post_init__(self):
        if not self.problem_id:
            self.problem_id = str(uuid.uuid4())


@dataclass
class ReasoningStep:
    """Individual reasoning step in mathematical problem solving"""
    step_id: str
    step_type: str
    mathematical_operation: str
    input_state: str
    output_state: str
    justification: str
    confidence: float
    validation_status: str = "pending"
    
    def __post_init__(self):
        if not self.step_id:
            self.step_id = str(uuid.uuid4())


@dataclass
class ReasoningTrajectory:
    """Complete reasoning path for a mathematical problem"""
    trajectory_id: str
    problem_id: str
    reasoning_steps: List[ReasoningStep]
    overall_approach: str
    trajectory_confidence: float
    completeness_score: float = 0.0
    correctness_score: float = 0.0
    
    def __post_init__(self):
        if not self.trajectory_id:
            self.trajectory_id = str(uuid.uuid4())


@dataclass
class StepValidation:
    """Validation results for a reasoning step"""
    step_id: str
    mathematical_validity: float
    logical_consistency: float
    computational_accuracy: float
    step_necessity: float
    validation_rationale: str
    
    @property
    def overall_validity(self) -> float:
        """Calculate overall validity score"""
        return (self.mathematical_validity + self.logical_consistency + 
                self.computational_accuracy + self.step_necessity) / 4


@dataclass
class TrajectoryScore:
    """Scoring results for a complete trajectory"""
    trajectory_id: str
    step_scores: List[StepValidation]
    overall_score: float
    approach_quality: float
    solution_correctness: float
    reasoning_clarity: float
    promotion_recommended: bool
    
    @property
    def average_step_score(self) -> float:
        """Calculate average step validation score"""
        if not self.step_scores:
            return 0.0
        return sum(score.overall_validity for score in self.step_scores) / len(self.step_scores)


class ProblemType(Enum):
    """Mathematical problem type categories"""
    ALGEBRA = "algebra"
    GEOMETRY = "geometry"
    CALCULUS = "calculus"
    COMBINATORICS = "combinatorics"
    GAME_THEORY = "game_theory"
    PROBABILITY = "probability"
    NUMBER_THEORY = "number_theory"


class StepType(Enum):
    """Types of reasoning steps"""
    COMPUTATION = "computation"
    LOGICAL_INFERENCE = "logical_inference"
    FORMULA_APPLICATION = "formula_application"
    PROBLEM_TRANSFORMATION = "problem_transformation"
    ALGEBRAIC_MANIPULATION = "algebraic_manipulation"
    SUBSTITUTION = "substitution"
    SYSTEM_SETUP = "system_setup"
    PATTERN_RECOGNITION = "pattern_recognition"


class ValidationStatus(Enum):
    """Validation status for reasoning steps"""
    PENDING = "pending"
    VALID = "valid"
    INVALID = "invalid"
    NEEDS_REVIEW = "needs_review"


@dataclass
class ReasoningContext:
    """Context for mathematical reasoning process"""
    problem: MathProblem
    available_tools: List[str]
    time_limit: Optional[int] = None
    confidence_threshold: float = 0.7
    max_trajectories: int = 3
    
    def __post_init__(self):
        if self.time_limit is None:
            self.time_limit = 1800  # 30 minutes default


@dataclass
class ReasoningResult:
    """Final result of mathematical reasoning process"""
    problem_id: str
    best_trajectory: ReasoningTrajectory
    all_trajectories: List[ReasoningTrajectory]
    final_answer: str
    confidence: float
    processing_time: float
    validation_summary: Dict[str, Any]
    
    @property
    def success(self) -> bool:
        """Check if reasoning was successful"""
        return self.confidence >= 0.7 and self.final_answer != ""


# Utility functions for SMARS type manipulation

def create_math_problem(statement: str, problem_type: str, difficulty: str = "medium") -> MathProblem:
    """Factory function to create MathProblem instances"""
    return MathProblem(
        problem_id="",  # Will be auto-generated
        problem_statement=statement,
        problem_type=problem_type,
        difficulty_level=difficulty,
        expected_steps=5,  # Default estimate
        validation_criteria=["mathematical_validity", "logical_consistency"]
    )


def create_reasoning_step(step_type: str, operation: str, input_state: str, 
                         output_state: str, justification: str, confidence: float = 0.8) -> ReasoningStep:
    """Factory function to create ReasoningStep instances"""
    return ReasoningStep(
        step_id="",  # Will be auto-generated
        step_type=step_type,
        mathematical_operation=operation,
        input_state=input_state,
        output_state=output_state,
        justification=justification,
        confidence=confidence
    )


def create_trajectory(problem_id: str, steps: List[ReasoningStep], 
                     approach: str, confidence: float = 0.8) -> ReasoningTrajectory:
    """Factory function to create ReasoningTrajectory instances"""
    return ReasoningTrajectory(
        trajectory_id="",  # Will be auto-generated
        problem_id=problem_id,
        reasoning_steps=steps,
        overall_approach=approach,
        trajectory_confidence=confidence
    )


def validate_step(step: ReasoningStep, context: Optional[ReasoningContext] = None) -> StepValidation:
    """Basic validation function for reasoning steps"""
    # This is a placeholder - real validation would involve mathematical checking
    base_validity = min(step.confidence, 0.9)
    
    return StepValidation(
        step_id=step.step_id,
        mathematical_validity=base_validity,
        logical_consistency=base_validity,
        computational_accuracy=base_validity,
        step_necessity=base_validity,
        validation_rationale=f"Basic validation of {step.step_type} step"
    )


def score_trajectory(trajectory: ReasoningTrajectory, step_validations: List[StepValidation]) -> TrajectoryScore:
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
    
    avg_validity = sum(v.overall_validity for v in step_validations) / len(step_validations)
    
    return TrajectoryScore(
        trajectory_id=trajectory.trajectory_id,
        step_scores=step_validations,
        overall_score=avg_validity,
        approach_quality=avg_validity,
        solution_correctness=avg_validity,
        reasoning_clarity=avg_validity,
        promotion_recommended=avg_validity >= 0.8
    )


if __name__ == "__main__":
    # Test the type system
    problem = create_math_problem(
        "Solve 2x + 3 = 7",
        "algebra",
        "easy"
    )
    
    step = create_reasoning_step(
        "algebraic_manipulation",
        "subtract 3 from both sides",
        "2x + 3 = 7",
        "2x = 4",
        "Isolate the term with x",
        0.9
    )
    
    trajectory = create_trajectory(
        problem.problem_id,
        [step],
        "direct_algebraic_solution",
        0.9
    )
    
    validation = validate_step(step)
    score = score_trajectory(trajectory, [validation])
    
    print(f"Problem: {problem.problem_statement}")
    print(f"Step: {step.mathematical_operation}")
    print(f"Validation: {validation.overall_validity:.2f}")
    print(f"Score: {score.overall_score:.2f}")
    print(f"Promoted: {score.promotion_recommended}")