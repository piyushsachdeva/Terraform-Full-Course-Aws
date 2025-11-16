# Simple Image Processor - Backend Only

A simplified serverless image processing pipeline that automatically processes images uploaded to S3.

## 🎯 Architecture

```
┌─────────────────┐
│  Upload Image   │  You upload image via AWS CLI or SDK
│   to S3 Bucket  │
└────────┬────────┘
         │ s3:ObjectCreated:* event
         ↓
┌─────────────────┐
│ Lambda Function │  Automatically triggered
│ Image Processor │  - Compresses JPEG (quality 85)
└────────┬────────┘  - Low quality JPEG (quality 60)
         │            - WebP format
         │            - PNG format
         │            - Thumbnail (200x200)
         ↓
┌─────────────────┐
│ Processed S3    │  5 variants saved automatically
│    Bucket       │
└─────────────────┘
```

## 📦 Components

- **Upload S3 Bucket**: Source bucket for original images
- **Processed S3 Bucket**: Destination bucket for processed variants
- **Lambda Function**: Image processor with Pillow library
- **Lambda Layer**: Pillow 10.4.0 for image manipulation
- **S3 Event Trigger**: Automatically invokes Lambda on upload

## 🚀 Deployment

```bash
# Deploy infrastructure
./scripts/deploy.sh

# The script will output your bucket names
```

## 📸 Usage

### Upload an Image

```bash
# Upload via AWS CLI
aws s3 cp my-photo.jpg s3://YOUR-UPLOAD-BUCKET/

# Or use the output from deployment
aws s3 cp my-photo.jpg $(terraform output -raw upload_command_example | awk '{print $NF}')
```

### View Processed Images

```bash
# List all processed variants
aws s3 ls s3://YOUR-PROCESSED-BUCKET/ --recursive

# Download a specific variant
aws s3 cp s3://YOUR-PROCESSED-BUCKET/my-photo_compressed.jpg ./
```

## 🎨 Generated Variants

For each uploaded image, the Lambda function creates:

1. **Compressed JPEG** (85% quality) - Best balance of quality/size
2. **Low Quality JPEG** (60% quality) - Smallest file size
3. **WebP Format** (85% quality) - Modern format, better compression
4. **PNG Format** - Lossless, largest file size
5. **Thumbnail** (200x200) - Small preview image

### Example Output

```
Original: photo.jpg (500 KB)
├── photo_compressed_abc123.jpg (120 KB)
├── photo_low_abc123.jpg (80 KB)
├── photo_webp_abc123.webp (95 KB)
├── photo_png_abc123.png (450 KB)
└── photo_thumbnail_abc123.jpg (15 KB)
```

## 🔧 Configuration

### Environment Variables (Lambda)

- `PROCESSED_BUCKET`: Destination S3 bucket name (auto-configured)
- `LOG_LEVEL`: Logging level (default: INFO)

### Supported Formats

**Input**: JPG, JPEG, PNG, WebP, GIF, BMP
**Output**: JPEG, PNG, WebP

## 📊 Monitoring

```bash
# View Lambda logs
aws logs tail /aws/lambda/YOUR-LAMBDA-FUNCTION --follow

# Check Lambda invocations
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=YOUR-LAMBDA-FUNCTION \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## 🧹 Cleanup

```bash
# Destroy all resources
./scripts/destroy.sh
```

## 💰 Cost Estimation

**Monthly costs** (approximate):

- **S3 Storage**: $0.023 per GB (first 50 TB)
- **Lambda**: First 1M requests free, then $0.20 per 1M
- **Lambda Duration**: First 400,000 GB-seconds free
- **S3 Requests**: $0.0004 per 1,000 PUT requests

**Example**: Processing 1,000 images/month ≈ **$0.50 - $2.00**

## 🔐 Security Features

- ✅ All buckets are private (no public access)
- ✅ Server-side encryption (AES256)
- ✅ Bucket versioning enabled
- ✅ IAM least privilege (Lambda only has access to specific buckets)
- ✅ VPC isolation (optional, not configured by default)

## 🎯 Performance

- **Cold Start**: ~470ms (includes Pillow layer loading)
- **Warm Execution**: ~300-600ms per image
- **Memory**: 113 MB average (1024 MB allocated)
- **Processing**: ~100ms per variant

## 🛠️ Customization

### Modify Image Quality

Edit `lambda/lambda_function.py`:

```python
# Change compression levels
COMPRESSION_LEVELS = {
    'compressed': 85,  # Change this
    'low': 60,         # Or this
    'webp': 85,        # WebP quality
}
```

### Change Thumbnail Size

```python
THUMBNAIL_SIZE = (200, 200)  # Change dimensions
```

### Add New Variants

```python
# Add in create_variants() function
variants['your_variant'] = img.copy()
variants['your_variant'].save(buffer, format='JPEG', quality=75)
```

## 📝 Notes

- Lambda timeout: 60 seconds (adjustable in `terraform/main.tf`)
- Max image size: Limited by Lambda memory (1024 MB)
- Supported regions: All AWS regions
- No frontend required - pure backend automation
