# 📊 Performance Monitoring Guide

## 🚀 Available Commands

### Main Commands

```bash
//gs c perf enable    # Enable monitoring
//gs c perf disable   # Disable monitoring
//gs c perf report    # Display performance report
//gs c perf reset     # Reset metrics
//gs c perf verbose   # Toggle verbose mode
//gs c perf test      # Test monitoring (simulates a slow operation)
```

## 📈 Monitoring States

### When ENABLED (`//gs c perf enable`)

```text
====================================
  PERFORMANCE MONITORING
====================================
[ACTIVE] Monitoring is now recording:
  - Equipment change times
  - Spell and JA performance
  - System response times

Use '//gs c perf report' to view the report
====================================
```

### When DISABLED (`//gs c perf disable`)

```text
====================================
  PERFORMANCE MONITORING
====================================
[DISABLED] Monitoring stopped
Collected data is preserved
Use '//gs c perf report' to view the final report
====================================
```

## 📊 Understanding the Report

When you run `//gs c perf report`:

### If ENABLED

```text
=====================================
    PERFORMANCE REPORT
=====================================
[ACTIVE] Session: 5m 32s

[STATISTICS]
  Total operations: 127
  (Each spell = precast + midcast + aftercast)
  Slow operations: 3 (Excellent!)
  Critical operations: 0 (Perfect!)

[SLOWEST OPERATIONS]
  equip_set [OK]: 45.2ms avg (max 102.5ms, 25x)
  precast_Cure [OK]: 23.1ms avg (max 48.3ms, 10x)
=====================================
```

### If DISABLED

```text
=====================================
    PERFORMANCE REPORT
=====================================
[STOPPED] Monitoring is not active
Use '//gs c perf enable' to activate it
=====================================
```

## 🎯 Performance Thresholds

- **✅ [OK]**: < 50ms (Excellent)
- **⚠️ [WARNING]**: 50-100ms (Acceptable)
- **❌ [SLOW]**: > 100ms (Potential issue)

## 🔍 Verbose Mode

Enable with `//gs c perf verbose` to see real-time alerts:

- Shows each slow operation immediately
- Useful for debugging
- Can be spammy during combat

## 🧪 System Test

```bash
//gs c perf test
```

- Simulates a 75ms operation (WARNING)
- Verifies that monitoring is working
- Check the report afterward to see the result

## 📝 Recommended Workflow

1. **Enable monitoring**

   ```bash
   //gs c perf enable
   ```

2. **Play normally** for 5-10 minutes

3. **Check the report**

   ```bash
   //gs c perf report
   ```

4. **If operations are slow**, enable verbose

   ```bash
   //gs c perf verbose
   ```

5. **Identify issues** in real-time

6. **Disable when finished**

   ```bash
   //gs c perf disable
   ```

## ⚠️ Important Notes

### Monitoring is DISABLED by default

- Normal to avoid overhead
- Only enable when testing/debugging

### Metrics are lost on reload

- Generate a report before reloading GearSwap
- Data is not persistent

### Performance impact

- Monitoring itself has < 1ms overhead
- Negligible during normal use
- Verbose mode may cause chat spam

## 🐛 Troubleshooting

### "Monitoring is currently DISABLED"

**Solution**: Enable first with `//gs c perf enable`

### No operations in report

**Possible causes**:

- Monitoring was just activated
- No actions performed since activation
- Test with `//gs c perf test` to verify

### Too many verbose messages

**Solution**: Disable verbose with `//gs c perf verbose`

## 💡 Tips

1. **For BST**: Monitor `pet_*` operations
2. **For BLM**: Monitor `midcast_BlackMagic`
3. **General**: `equip_set` should be < 50ms

## 📞 Support

If you consistently see operations > 100ms:

1. Note which operations are slow
2. Report with the job used
3. Include the complete report (`//gs c perf report`)

---

Version 2.0.0 - User-Friendly Interface - August 2025
