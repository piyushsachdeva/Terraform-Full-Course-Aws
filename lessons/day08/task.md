# Task for Day 08 - Meta-Arguments (count and for_each)

## Learning Objectives
- Understand the concepts of `for_each`, `for` loop, and `count` meta-arguments in Terraform
- Learn when to use `count` vs `for_each`
- Practice creating multiple AWS resources efficiently

## Tasks

### Task 1: Understanding COUNT
**Objective**: Create two S3 buckets using a single resource block with `count`

1. Create a variable of type `list(string)` for bucket names
2. Use `count` to iterate through the bucket names
3. Reference bucket names using `count.index`
4. Run `terraform plan` to see the resources

### Task 2: Understanding FOR_EACH
**Objective**: Create two S3 buckets using a single resource block with `for_each`

1. Create a variable of type `set(string)` for bucket names
2. Use `for_each` to iterate through the bucket names
3. Reference bucket names using `each.value`
4. Compare resource addressing: `[0]` vs `["bucket-name"]`

### Task 3: Output with FOR Loop
**Objective**: Display bucket information using `for` expressions

1. Create output to print all bucket names using a `for` loop
2. Create output to print all bucket IDs using a `for` expression
3. Run `terraform output` to verify

## Key Concepts

**When to use COUNT:**
- Simple scenarios with identical resources
- Resources identified by numeric index

**When to use FOR_EACH:**
- Resources need unique identifiers
- More stable when adding/removing items
- Better for production environments

## Quick Tasks

### What to Do
- [ ] Watch the Day 08 video and take notes
- [ ] Write a short blog (500-800 words) about what you learned
    - Include your own diagrams and code examples
    - Embed the video
- [ ] Share your blog on LinkedIn and Twitter/X with **#30daysofawsterraform**
- [ ] Tag Piyush Sachdeva
- [ ] Submit your work (see `submission.md` for instructions)

### Tips
- Keep it simple and clear
- Feel free to take AI assistance but do not overuse it
- Use your own diagrams
- Engage with others' posts

Good luck! 🚀

## Notes

⚠️ **Important**: S3 bucket names must be globally unique!  
💡 **Tip**: Use `terraform console` to experiment with `for` expressions!
