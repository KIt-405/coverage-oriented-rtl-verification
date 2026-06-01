import re
import json
import sys
import os

def parse_simulation_report(log_path):
    mismatch_counter = 0
    assertion_failures = 0
    match_counter = 0
    coverage_score = 0.0 
    
    error_log = [] 

    mismatch_regex = re.compile(r"\[SCB_ERROR\]")
    assertion_regex = re.compile(r"\[SVA_ERROR\]")
    

    match_regex = re.compile(r"Total Success Checked Matches\s*:\s*(\d+)")
    coverage_regex = re.compile(r"Final System Coverage Metric\s*:\s*([0-9.]+)\%")

    if not os.path.exists(log_path):
        print(f"Error: Log file '{log_path}' not found. Did the simulation run?")
        sys.exit(1)

    try:
        with open(log_path, 'r') as file:
            for line in file:
                if mismatch_regex.search(line):
                    mismatch_counter += 1
                    error_log.append(line.strip())
                
                if assertion_regex.search(line):
                    assertion_failures += 1
                    error_log.append(line.strip())
                
                match_succ = match_regex.search(line)
                if match_succ:
                    match_counter = int(match_succ.group(1))

                match_cov = coverage_regex.search(line)
                if match_cov:
                    coverage_score = float(match_cov.group(1))
                    
    except Exception as e:
        print(f"Error reading file '{log_path}': {e}")
        sys.exit(1)

    is_passing = (mismatch_counter == 0 and assertion_failures == 0 and coverage_score > 0)

    summary_report = {
        "functional_coverage_percentage": coverage_score,
        "scoreboard_matches": match_counter,
        "scoreboard_mismatches": mismatch_counter,
        "sva_assertions_tripped": assertion_failures,
        "status": "PASSED" if is_passing else "FAILED",
    }

    if not is_passing and len(error_log) > 0:
        summary_report["Error_Details"] = error_log

    print("\n=== POST-SIMULATION ANALYSIS SUMMARY ===")
    print(json.dumps(summary_report, indent=4))

if __name__ == "__main__":
    target_log = sys.argv[1] if len(sys.argv) > 1 else "sim_output.log"
    parse_simulation_report(target_log)
