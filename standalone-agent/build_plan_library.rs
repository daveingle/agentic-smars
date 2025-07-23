use std::env;
use std::path::Path;

// Import our plan library module
mod src {
    pub mod plan_library;
}

use src::plan_library::PlanLibraryBuilder;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🔧 Building SMARS Plan Library...");
    
    // Get the parent directory (agentic-smars root)
    let current_dir = env::current_dir()?;
    let smars_root = current_dir.parent()
        .ok_or("Could not find parent directory")?
        .to_string_lossy()
        .to_string();
    
    println!("📁 SMARS root: {}", smars_root);
    
    // Build the plan library
    let mut builder = PlanLibraryBuilder::new(&smars_root);
    builder.build_library()?;
    
    // Save the library
    let output_path = current_dir.join("plan_library").join("plan_library.json");
    std::fs::create_dir_all(output_path.parent().unwrap())?;
    builder.save_library(&output_path.to_string_lossy())?;
    
    println!("✅ Plan library build complete!");
    println!("📦 Library saved to: {}", output_path.display());
    
    Ok(())
}