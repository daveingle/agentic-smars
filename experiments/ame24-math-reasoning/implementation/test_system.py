"""
Test Script for SMARS Mathematical Reasoning System
Execute actual system tests on AIME 2024 problems
"""

import sys
import os
import json
import time
from datetime import datetime
from typing import Dict, List, Any

# Add the implementation directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from reasoning_engine import MathematicalReasoningEngine
from smars_types import ReasoningResult


class SystemTester:
    """Test harness for SMARS mathematical reasoning system"""
    
    def __init__(self):
        self.engine = MathematicalReasoningEngine()
        self.test_problems = self._load_test_problems()
        self.ground_truth = self._load_ground_truth()
        self.results = []
    
    def _load_test_problems(self) -> Dict[str, str]:
        """Load test problems from our cached set"""
        return {
            "problem_1": """Every morning Aya goes for a 9-kilometer-long walk and stops at a coffee shop afterwards. When she walks at a constant speed of s kilometers per hour, the walk takes her 4 hours, including t minutes spent in the coffee shop. When she walks at s + 2 kilometers per hour, the walk takes her 2 hours and 24 minutes, including t minutes spent in the coffee shop. Suppose Aya walks at s + 1/2 kilometers per hour. Find the number of minutes the walk takes her, including the t minutes spent in the coffee shop.""",
            
            "problem_2": """There exist real numbers x and y, both greater than 1, such that log_x(y^x) = log_y(x^(4y)) = 10. Find xy.""",
            
            "problem_3": """Alice and Bob play the following game. A stack of n tokens lies before them. The players take turns with Alice going first. On each turn, the player removes 1 token or 4 tokens from the stack. The player who removes the last token wins. Find the number of positive integers n less than or equal to 2024 such that there is a strategy that guarantees that Bob wins, regardless of Alice's moves."""
        }
    
    def _load_ground_truth(self) -> Dict[str, str]:
        """Load ground truth answers from our manual solutions"""
        return {
            "problem_1": "204",
            "problem_2": "25", 
            "problem_3": "809"
        }
    
    def run_single_test(self, problem_id: str, problem_statement: str) -> Dict[str, Any]:
        """Run a single test case"""
        print(f"\n{'='*60}")
        print(f"TESTING: {problem_id.upper()}")
        print(f"{'='*60}")
        
        start_time = time.time()
        
        try:
            # Execute the reasoning loop
            result = self.engine.execute_reasoning_loop(problem_statement)
            
            # Check correctness
            expected_answer = self.ground_truth.get(problem_id, "unknown")
            is_correct = result.final_answer == expected_answer
            
            test_result = {
                "problem_id": problem_id,
                "expected_answer": expected_answer,
                "system_answer": result.final_answer,
                "correct": is_correct,
                "confidence": result.confidence,
                "processing_time": result.processing_time,
                "trajectory_count": len(result.all_trajectories),
                "average_validity": result.validation_summary.get("average_validity", 0.0),
                "total_steps": result.validation_summary.get("total_steps", 0),
                "timestamp": datetime.now().isoformat()
            }
            
            # Print results
            print(f"Expected Answer: {expected_answer}")
            print(f"System Answer: {result.final_answer}")
            print(f"Correct: {'✓' if is_correct else '✗'}")
            print(f"Confidence: {result.confidence:.3f}")
            print(f"Processing Time: {result.processing_time:.2f}s")
            print(f"Trajectories Generated: {len(result.all_trajectories)}")
            print(f"Total Steps: {result.validation_summary.get('total_steps', 0)}")
            print(f"Average Validity: {result.validation_summary.get('average_validity', 0.0):.3f}")
            
            # Show trajectory details
            print(f"\nTrajectory Details:")
            for i, trajectory in enumerate(result.all_trajectories):
                print(f"  Trajectory {i+1}: {trajectory.overall_approach}")
                print(f"    Steps: {len(trajectory.reasoning_steps)}")
                print(f"    Confidence: {trajectory.trajectory_confidence:.3f}")
                
                # Show first few steps
                print(f"    Sample Steps:")
                for j, step in enumerate(trajectory.reasoning_steps[:3]):
                    print(f"      {j+1}. {step.step_type}: {step.mathematical_operation}")
                    print(f"         {step.input_state} → {step.output_state}")
                if len(trajectory.reasoning_steps) > 3:
                    print(f"      ... and {len(trajectory.reasoning_steps) - 3} more steps")
            
            return test_result
            
        except Exception as e:
            print(f"ERROR: {str(e)}")
            
            error_result = {
                "problem_id": problem_id,
                "expected_answer": self.ground_truth.get(problem_id, "unknown"),
                "system_answer": "ERROR",
                "correct": False,
                "confidence": 0.0,
                "processing_time": time.time() - start_time,
                "trajectory_count": 0,
                "average_validity": 0.0,
                "total_steps": 0,
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
            
            return error_result
    
    def run_all_tests(self) -> List[Dict[str, Any]]:
        """Run all test cases"""
        print("SMARS Mathematical Reasoning System Test")
        print("="*60)
        print(f"Testing {len(self.test_problems)} problems")
        print(f"Test started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        results = []
        
        for problem_id, problem_statement in self.test_problems.items():
            result = self.run_single_test(problem_id, problem_statement)
            results.append(result)
            self.results.append(result)
        
        # Print summary
        self._print_test_summary(results)
        
        return results
    
    def _print_test_summary(self, results: List[Dict[str, Any]]):
        """Print test summary"""
        print(f"\n{'='*60}")
        print("TEST SUMMARY")
        print(f"{'='*60}")
        
        total_tests = len(results)
        correct_tests = sum(1 for r in results if r["correct"])
        error_tests = sum(1 for r in results if r["system_answer"] == "ERROR")
        
        print(f"Total Tests: {total_tests}")
        print(f"Correct: {correct_tests}")
        print(f"Incorrect: {total_tests - correct_tests - error_tests}")
        print(f"Errors: {error_tests}")
        print(f"Accuracy: {correct_tests/total_tests*100:.1f}%")
        
        if results:
            avg_confidence = sum(r["confidence"] for r in results) / len(results)
            avg_processing_time = sum(r["processing_time"] for r in results) / len(results)
            avg_trajectories = sum(r["trajectory_count"] for r in results) / len(results)
            avg_validity = sum(r["average_validity"] for r in results) / len(results)
            
            print(f"\nAverage Metrics:")
            print(f"  Confidence: {avg_confidence:.3f}")
            print(f"  Processing Time: {avg_processing_time:.2f}s")
            print(f"  Trajectories per Problem: {avg_trajectories:.1f}")
            print(f"  Validation Score: {avg_validity:.3f}")
        
        print(f"\nDetailed Results:")
        for result in results:
            status = "✓" if result["correct"] else "✗"
            print(f"  {result['problem_id']}: {status} {result['system_answer']} (expected: {result['expected_answer']})")
    
    def save_results(self, filename: str = "test_results.json"):
        """Save test results to file"""
        results_dir = os.path.join(os.path.dirname(__file__), "..", "results")
        os.makedirs(results_dir, exist_ok=True)
        
        filepath = os.path.join(results_dir, filename)
        
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\nResults saved to: {filepath}")
    
    def run_validation_analysis(self) -> Dict[str, Any]:
        """Run detailed validation analysis"""
        print(f"\n{'='*60}")
        print("VALIDATION ANALYSIS")
        print(f"{'='*60}")
        
        validation_stats = {
            "framework_components": {
                "problem_parsing": self._analyze_problem_parsing(),
                "trajectory_generation": self._analyze_trajectory_generation(),
                "step_validation": self._analyze_step_validation(),
                "trajectory_scoring": self._analyze_trajectory_scoring(),
                "trajectory_selection": self._analyze_trajectory_selection()
            },
            "mathematical_correctness": self._analyze_mathematical_correctness(),
            "system_performance": self._analyze_system_performance()
        }
        
        # Print analysis
        for component, analysis in validation_stats["framework_components"].items():
            print(f"\n{component.upper()}: {analysis['status']}")
            if analysis.get("details"):
                for detail in analysis["details"]:
                    print(f"  - {detail}")
        
        print(f"\nMATHEMATICAL CORRECTNESS: {validation_stats['mathematical_correctness']['accuracy']:.1f}%")
        print(f"SYSTEM PERFORMANCE: {validation_stats['system_performance']['overall_score']:.3f}")
        
        return validation_stats
    
    def _analyze_problem_parsing(self) -> Dict[str, Any]:
        """Analyze problem parsing component"""
        # Check if problems were parsed correctly
        parsed_correctly = 0
        total_problems = len(self.results)
        
        for result in self.results:
            if result["system_answer"] != "ERROR":
                parsed_correctly += 1
        
        success_rate = parsed_correctly / total_problems if total_problems > 0 else 0
        
        return {
            "status": "✓ FUNCTIONAL" if success_rate >= 0.8 else "✗ NEEDS WORK",
            "success_rate": success_rate,
            "details": [
                f"Successfully parsed {parsed_correctly}/{total_problems} problems",
                f"Success rate: {success_rate*100:.1f}%"
            ]
        }
    
    def _analyze_trajectory_generation(self) -> Dict[str, Any]:
        """Analyze trajectory generation component"""
        total_trajectories = sum(r["trajectory_count"] for r in self.results)
        avg_trajectories = total_trajectories / len(self.results) if self.results else 0
        
        return {
            "status": "✓ FUNCTIONAL" if avg_trajectories >= 2 else "✗ NEEDS WORK",
            "avg_trajectories": avg_trajectories,
            "details": [
                f"Generated {total_trajectories} total trajectories",
                f"Average {avg_trajectories:.1f} trajectories per problem",
                "Multiple approaches generated" if avg_trajectories >= 2 else "Single approach only"
            ]
        }
    
    def _analyze_step_validation(self) -> Dict[str, Any]:
        """Analyze step validation component"""
        avg_validity = sum(r["average_validity"] for r in self.results) / len(self.results) if self.results else 0
        
        return {
            "status": "✓ FUNCTIONAL" if avg_validity >= 0.7 else "✗ NEEDS WORK",
            "avg_validity": avg_validity,
            "details": [
                f"Average validation score: {avg_validity:.3f}",
                f"Validation {'effective' if avg_validity >= 0.7 else 'needs improvement'}"
            ]
        }
    
    def _analyze_trajectory_scoring(self) -> Dict[str, Any]:
        """Analyze trajectory scoring component"""
        avg_confidence = sum(r["confidence"] for r in self.results) / len(self.results) if self.results else 0
        
        return {
            "status": "✓ FUNCTIONAL" if avg_confidence >= 0.6 else "✗ NEEDS WORK",
            "avg_confidence": avg_confidence,
            "details": [
                f"Average trajectory confidence: {avg_confidence:.3f}",
                f"Scoring {'effective' if avg_confidence >= 0.6 else 'needs calibration'}"
            ]
        }
    
    def _analyze_trajectory_selection(self) -> Dict[str, Any]:
        """Analyze trajectory selection component"""
        # Check if best trajectories were selected (based on correctness)
        correct_selections = sum(1 for r in self.results if r["correct"])
        selection_rate = correct_selections / len(self.results) if self.results else 0
        
        return {
            "status": "✓ FUNCTIONAL" if selection_rate >= 0.7 else "✗ NEEDS WORK",
            "selection_rate": selection_rate,
            "details": [
                f"Correct selections: {correct_selections}/{len(self.results)}",
                f"Selection accuracy: {selection_rate*100:.1f}%"
            ]
        }
    
    def _analyze_mathematical_correctness(self) -> Dict[str, Any]:
        """Analyze mathematical correctness"""
        correct_answers = sum(1 for r in self.results if r["correct"])
        accuracy = correct_answers / len(self.results) if self.results else 0
        
        return {
            "accuracy": accuracy * 100,
            "correct_count": correct_answers,
            "total_count": len(self.results)
        }
    
    def _analyze_system_performance(self) -> Dict[str, Any]:
        """Analyze overall system performance"""
        if not self.results:
            return {"overall_score": 0.0}
        
        accuracy = sum(1 for r in self.results if r["correct"]) / len(self.results)
        avg_confidence = sum(r["confidence"] for r in self.results) / len(self.results)
        avg_validity = sum(r["average_validity"] for r in self.results) / len(self.results)
        
        # Weight accuracy most heavily
        overall_score = 0.5 * accuracy + 0.3 * avg_confidence + 0.2 * avg_validity
        
        return {
            "overall_score": overall_score,
            "accuracy": accuracy,
            "avg_confidence": avg_confidence,
            "avg_validity": avg_validity
        }


def main():
    """Run the complete system test"""
    tester = SystemTester()
    
    # Run all tests
    results = tester.run_all_tests()
    
    # Run validation analysis
    validation_stats = tester.run_validation_analysis()
    
    # Save results
    tester.save_results("actual_system_test_results.json")
    
    # Save validation analysis
    validation_dir = os.path.join(os.path.dirname(__file__), "..", "results")
    os.makedirs(validation_dir, exist_ok=True)
    
    validation_file = os.path.join(validation_dir, "validation_analysis.json")
    with open(validation_file, 'w') as f:
        json.dump(validation_stats, f, indent=2)
    
    print(f"\nValidation analysis saved to: {validation_file}")
    
    return results, validation_stats


if __name__ == "__main__":
    main()