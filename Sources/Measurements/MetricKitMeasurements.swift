//
// MetricKitAppMetrics
// Memoirs
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

#if canImport(MetricKit) && os(iOS)

import MetricKit

@available(iOS 13.0, *)
public class MetricKitMeasurements: NSObject, MXMetricManagerSubscriber {
    private var memoir: Memoir
    private var metricManager: MXMetricManager?

    public init(memoir: Memoir) {
        self.memoir = memoir
        metricManager = MXMetricManager.shared
        super.init()

        metricManager?.add(self)
    }

    deinit {
        metricManager?.remove(self)
    }

    // MARK: - Metrics transformations

    private typealias NameValueAndMeta = [String: (value: MeasurementValue, meta: [String: SafeString]?)]

    private func processMemoryMetric(_ metric: MXMemoryMetric, into metrics: inout NameValueAndMeta) {
        let keyMemoryMetric = "iOSMetric.memory"
        let keyMemoryAverageSuspendedMemory = "averageSuspended.bytes"
        let keyMemoryPeakUsage = "peakUsage.bytes"

        let meta: [String: SafeString] = [
            keyMemoryAverageSuspendedMemory: "\(safe: Int(metric.averageSuspendedMemory.averageMeasurement.converted(to: .bytes).value))",
            keyMemoryPeakUsage: "\(safe: Int(metric.peakMemoryUsage.converted(to: .bytes).value))",
        ]
        metrics[keyMemoryMetric] = (value: .meta, meta: meta)
    }

    private func processCPUMetric(_ metric: MXCPUMetric, into metrics: inout NameValueAndMeta) {
        let keyCPUMetric = "iOSMetric.cpu"
        let keyCPUCumulativeTime = "cumulativeTime.secs"
        let keyCPUCumulativeInstructions = "cumulativeInstructions.secs"

        var meta: [String: SafeString] = [
            keyCPUCumulativeTime: "\(safe: Int(metric.cumulativeCPUTime.converted(to: .seconds).value))"
        ]
        if #available(iOS 14.0, *) {
            meta[keyCPUCumulativeInstructions] = "\(safe: Int64(metric.cumulativeCPUInstructions.value))"
        }
        metrics[keyCPUMetric] = (value: .meta, meta: meta)
    }

    @available(iOS 14.0, *)private func processAnimationMetric(_ metric: MXAnimationMetric, into metrics: inout NameValueAndMeta) {
        let keyAnimationMetric = "iOSMetric.animation"
        let keyAnimationScrollHitchTimeRatio = "scrollHitchTimeRatio"

        let meta: [String: SafeString] = [
            keyAnimationScrollHitchTimeRatio: "\(safe: metric.scrollHitchTimeRatio.value)",
        ]
        metrics[keyAnimationMetric] = (value: .meta, meta: meta)
    }

    @available(iOS 14.0, *)
    private func processExitMetric(_ metric: MXAppExitMetric, into metrics: inout NameValueAndMeta) {
        let keyExitBackgroundMetric = "iOSMetric.exits.background"
        let keyExitBackgroundNormal = "normal"
        let keyExitBackgroundAbnormal = "abnormal"
        let keyExitBackgroundWatchdog = "watchdog"
        let keyExitBackgroundTaskAssertion = "taskAssertion"
        let keyExitBackgroundBadAccess = "badAccess"
        let keyExitBackgroundCPULimit = "cpuLimit"
        let keyExitBackgroundIllegalInstruction = "illegalInstruction"
        let keyExitBackgroundMemoryPressure = "memoryPressure"
        let keyExitBackgroundMemoryResource = "memoryResource"
        let keyExitBackgroundLockedFile = "lockedFile"

        let keyExitForegroundMetric = "iOSMetric.exits.foreground"
        let keyExitForegroundNormal = "normal"
        let keyExitForegroundAbnormal = "abnormal"
        let keyExitForegroundWatchdog = "watchdog"
        let keyExitForegroundBadAccess = "badAccess"
        let keyExitForegroundIllegalInstruction = "illegalInstruction"
        let keyExitForegroundResourceLimit = "resourceLimit"

        let metaBackground: [String: SafeString] = [
            keyExitBackgroundNormal: "\(safe: Int(metric.backgroundExitData.cumulativeNormalAppExitCount))",
            keyExitBackgroundAbnormal: "\(safe: Int(metric.backgroundExitData.cumulativeAbnormalExitCount))",
            keyExitBackgroundWatchdog: "\(safe: Int(metric.backgroundExitData.cumulativeAppWatchdogExitCount))",
            keyExitBackgroundTaskAssertion: "\(safe: Int(metric.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount))",
            keyExitBackgroundBadAccess: "\(safe: Int(metric.backgroundExitData.cumulativeBadAccessExitCount))",
            keyExitBackgroundCPULimit: "\(safe: Int(metric.backgroundExitData.cumulativeCPUResourceLimitExitCount))",
            keyExitBackgroundIllegalInstruction: "\(safe: Int(metric.backgroundExitData.cumulativeIllegalInstructionExitCount))",
            keyExitBackgroundMemoryPressure: "\(safe: Int(metric.backgroundExitData.cumulativeMemoryPressureExitCount))",
            keyExitBackgroundMemoryResource: "\(safe: Int(metric.backgroundExitData.cumulativeMemoryResourceLimitExitCount))",
            keyExitBackgroundLockedFile: "\(safe: Int(metric.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount))",
        ]
        let metaForeground: [String: SafeString] = [
            keyExitForegroundNormal: "\(safe: Int(metric.foregroundExitData.cumulativeNormalAppExitCount))",
            keyExitForegroundAbnormal: "\(safe: Int(metric.foregroundExitData.cumulativeAbnormalExitCount))",
            keyExitForegroundWatchdog: "\(safe: Int(metric.foregroundExitData.cumulativeAppWatchdogExitCount))",
            keyExitForegroundBadAccess: "\(safe: Int(metric.foregroundExitData.cumulativeBadAccessExitCount))",
            keyExitForegroundIllegalInstruction: "\(safe: Int(metric.foregroundExitData.cumulativeIllegalInstructionExitCount))",
            keyExitForegroundResourceLimit: "\(safe: Int(metric.foregroundExitData.cumulativeMemoryResourceLimitExitCount))",
        ]
        metrics[keyExitBackgroundMetric] = (value: .meta, meta: metaBackground)
        metrics[keyExitForegroundMetric] = (value: .meta, meta: metaForeground)
    }

    private func processLaunchMetric(_ metric: MXAppLaunchMetric, into metrics: inout NameValueAndMeta) {
        let keyLaunchMetric = "iOSMetric.launch"
        let keyLaunchTimeToFirstDraw = "timeToFirstDraw.secs"
        let keyLaunchResumeTime = "resumeTime.secs"

        let bucketsTimeToFirstDraw: [MeasurementValue.HistogramBucket] = metric.histogrammedTimeToFirstDraw.bucketEnumerator
            .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
            .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
        let bucketsResumeTime: [MeasurementValue.HistogramBucket] = metric.histogrammedApplicationResumeTime.bucketEnumerator
            .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
            .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }

        metrics["\(keyLaunchMetric).\(keyLaunchTimeToFirstDraw)"] = (.histogram(buckets: bucketsTimeToFirstDraw), [:])
        metrics["\(keyLaunchMetric).\(keyLaunchResumeTime)"] = (.histogram(buckets: bucketsResumeTime), [:])
    }

    private func processResponsivenessMetric(_ metric: MXAppResponsivenessMetric, into metrics: inout NameValueAndMeta) {
        let keyResponsivenessMetric = "iOSMetric.responsiveness"
        let keyResponsivenessHangTime = "hangTime.secs"

        let buckets: [MeasurementValue.HistogramBucket] = metric.histogrammedApplicationHangTime
            .bucketEnumerator
            .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
            .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
        metrics["\(keyResponsivenessMetric).\(keyResponsivenessHangTime)"] = (value: .histogram(buckets: buckets), meta: nil)
    }

    private func processAppRunTimeMetric(_ metric: MXAppRunTimeMetric, into metrics: inout NameValueAndMeta) {
        let keyTimeMetric = "iOSMetric.appTime"
        let keyTimeMetricsForeground = "foreground"
        let keyTimeMetricsBackground = "background"
        let keyTimeMetricsBackgroundAudio = "background.audio"
        let keyTimeMetricsBackgroundLocation = "background.location"

        let meta: [String: SafeString] = [
            keyTimeMetricsForeground: "\(safe: metric.cumulativeForegroundTime.converted(to: .seconds).value)",
            keyTimeMetricsBackground: "\(safe: metric.cumulativeBackgroundTime.converted(to: .seconds).value)",
            keyTimeMetricsBackgroundAudio: "\(safe: metric.cumulativeBackgroundAudioTime.converted(to: .seconds).value)",
            keyTimeMetricsBackgroundLocation: "\(safe: metric.cumulativeBackgroundLocationTime.converted(to: .seconds).value)",
        ]
        metrics[keyTimeMetric] = (value: .meta, meta: meta)
    }

    private func processCellularConditionsMetric(_ metric: MXCellularConditionMetric, into metrics: inout NameValueAndMeta) {
        let keyCellularMetric = "iOSMetric.cellular"
        let keyCellularConditionTime = "conditionTime.bars"

        let buckets: [MeasurementValue.HistogramBucket] = metric.histogrammedCellularConditionTime
            .bucketEnumerator
            .compactMap { $0 as? MXHistogramBucket<MXUnitSignalBars> }
            .map { MeasurementValue.HistogramBucket(range: rangeOfBars(for: $0), count: $0.bucketCount) }

        metrics["\(keyCellularMetric).\(keyCellularConditionTime)"] = (value: .histogram(buckets: buckets), meta: nil)
    }

    private func processDiskIOMetric(_ metric: MXDiskIOMetric, into metrics: inout NameValueAndMeta) {
        let keyDiskMetric = "iOSMetric.disk.writes.bytes"
        let keyDiskWrites = "writes.bytes"

        metrics["\(keyDiskMetric).\(keyDiskWrites)"] =
            (value: .double(metric.cumulativeLogicalWrites.converted(to: .bytes).value), meta: nil)
    }

    private func processDisplayMetric(_ metric: MXDisplayMetric, into metrics: inout NameValueAndMeta) {
        let keyDisplayMetric = "iOSMetric.display"
        let keyDisplayAverageLuminance = "luminance.average.apl"

        if let value = metric.averagePixelLuminance?.averageMeasurement.converted(to: .apl).value {
            metrics["\(keyDisplayMetric).\(keyDisplayAverageLuminance)"] = (value: .double(value), meta: nil)
        }
    }

    private func processGPUMetric(_ metric: MXGPUMetric, into metrics: inout NameValueAndMeta) {
        let keyGPUMetric = "iOSMetric.gpu"
        let keyGPUTime = "time.secs"

        metrics["\(keyGPUMetric).\(keyGPUTime)"] = (value: .double(metric.cumulativeGPUTime.converted(to: .seconds).value), meta: nil)
    }

    private func processLocationMetric(_ metric: MXLocationActivityMetric, into metrics: inout NameValueAndMeta) {
        let keyLocationMetric = "iOSMetric.location"
        let keyLocationNavigation = "navigation.secs"
        let keyLocationBest = "best.secs"
        let keyLocationTenMeters = "tenMeters.secs"
        let keyLocationHundredMeters = "hundredMeters.secs"
        let keyLocationKilometer = "kilometer.secs"
        let keyLocationThreeKilometers = "threeKilometers.secs"

        let meta: [String: SafeString] = [
            keyLocationNavigation: "\(safe: metric.cumulativeBestAccuracyForNavigationTime.converted(to: .seconds).value)",
            keyLocationBest: "\(safe: metric.cumulativeBestAccuracyTime.converted(to: .seconds).value)",
            keyLocationTenMeters: "\(safe: metric.cumulativeNearestTenMetersAccuracyTime.converted(to: .seconds).value)",
            keyLocationHundredMeters: "\(safe: metric.cumulativeHundredMetersAccuracyTime.converted(to: .seconds).value)",
            keyLocationKilometer: "\(safe: metric.cumulativeKilometerAccuracyTime.converted(to: .seconds).value)",
            keyLocationThreeKilometers: "\(safe: metric.cumulativeThreeKilometersAccuracyTime.converted(to: .seconds).value)",
        ]
        metrics[keyLocationMetric] = (value: .meta, meta: meta)
    }

    private func processNetworkTransferMetric(_ metric: MXNetworkTransferMetric, into metrics: inout NameValueAndMeta) {
        let keyNetworkMetric = "iOSMetric.net"
        let keyNetworkWifiUpload = "WifiUpload.bytes"
        let keyNetworkWifiDownload = "WifiDownload.bytes"
        let keyNetworkCellularUpload = "cellularUpload.bytes"
        let keyNetworkCellularDownload = "cellularDownload.bytes"

        let meta: [String: SafeString] = [
            keyNetworkWifiUpload: "\(safe: Int(metric.cumulativeWifiUpload.converted(to: .bytes).value))",
            keyNetworkWifiDownload: "\(safe: Int(metric.cumulativeWifiDownload.converted(to: .bytes).value))",
            keyNetworkCellularUpload: "\(safe: Int(metric.cumulativeCellularUpload.converted(to: .bytes).value))",
            keyNetworkCellularDownload: "\(safe: Int(metric.cumulativeCellularDownload.converted(to: .bytes).value))",
        ]
        metrics[keyNetworkMetric] = (value: .meta, meta: meta)
    }

    private func processSignpostMetrics(_ metric: MXSignpostMetric, into metrics: inout NameValueAndMeta) {
        let keySignpostPrefix = "iOSMetric.sp."

        var value: MeasurementValue = .meta
        var meta: [String: SafeString] = [:]
        if let interval = metric.signpostIntervalData {
            meta["count"] = "\(safe: Int(metric.totalCount))"
            if let value = interval.cumulativeCPUTime?.converted(to: .seconds).value {
                meta["cumulativeCPU.secs"] = "\(safe: value)"
            }
            if let value = interval.averageMemory?.averageMeasurement.converted(to: .bytes).value {
                meta["averageMemory.bytes"] = "\(safe: value)"
            }

            let buckets: [MeasurementValue.HistogramBucket] = interval.histogrammedSignpostDuration
                .bucketEnumerator
                .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
                .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
            value = .histogram(buckets: buckets)
        }
        metrics["\(keySignpostPrefix)\(metric.signpostCategory).\(metric.signpostName)"] = (value: value, meta: meta)
    }

    // MARK: - Diagnostics transformations

    @available(iOS 14.0, *)
    private func metaFor(crash diagnostic: MXCrashDiagnostic) -> [String: SafeString] {
        var meta: [String: SafeString] = [:]
        meta["type"] = diagnostic.exceptionType.map { "\(safe: $0)" }
        meta["code"] = diagnostic.exceptionCode.map { "\(safe: $0)" }
        meta["signal"] = diagnostic.signal.map { "\(safe: $0)" }
        meta["reason"] = diagnostic.terminationReason.map { "\(safe: $0)" }
        meta["memoryRegion"] = diagnostic.virtualMemoryRegionInfo.map { "\(safe: $0)" }
        meta["stack"] = String(data: diagnostic.callStackTree.jsonRepresentation(), encoding: .utf8).map { "\(safe: $0)" }
        return meta
    }

    @available(iOS 14.0, *)
    private func metaFor(cpuException diagnostic: MXCPUExceptionDiagnostic) -> [String: SafeString] {
        var meta: [String: SafeString] = [:]
        meta["totalCPU.secs"] = "\(safe: diagnostic.totalCPUTime.converted(to: .seconds).value)"
        meta["totalSampled.secs"] = "\(safe: diagnostic.totalSampledTime.converted(to: .seconds).value)"
        let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
        meta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
        return meta
    }

    @available(iOS 14.0, *)
    private func metaFor(hang diagnostic: MXHangDiagnostic) -> [String: SafeString] {
        var meta: [String: SafeString] = [:]
        meta["duration.secs"] = "\(safe: diagnostic.hangDuration.converted(to: .seconds).value)"
        let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
        meta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
        return meta
    }

    @available(iOS 14.0, *)
    private func metaFor(diskWriteException diagnostic: MXDiskWriteExceptionDiagnostic) -> [String: SafeString] {
        var meta: [String: SafeString] = [:]
        meta["total.bytes"] = "\(safe: diagnostic.totalWritesCaused.converted(to: .bytes).value)"
        let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
        meta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
        return meta
    }

    // MARK: - Delegate methods

    public func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach { payload in
            var metrics: NameValueAndMeta = [:]
            payload.cpuMetrics.map { processCPUMetric($0, into: &metrics) }
            payload.memoryMetrics.map { processMemoryMetric($0, into: &metrics) }
            if #available(iOS 14.0, *) {
                payload.animationMetrics.map { processAnimationMetric($0, into: &metrics) }
                payload.applicationExitMetrics.map { processExitMetric($0, into: &metrics) }
            }
            payload.applicationLaunchMetrics.map { processLaunchMetric($0, into: &metrics) }
            payload.applicationResponsivenessMetrics.map { processResponsivenessMetric($0, into: &metrics) }
            payload.applicationTimeMetrics.map { processAppRunTimeMetric($0, into: &metrics) }
            payload.cellularConditionMetrics.map { processCellularConditionsMetric($0, into: &metrics) }
            payload.diskIOMetrics.map { processDiskIOMetric($0, into: &metrics) }
            payload.displayMetrics.map { processDisplayMetric($0, into: &metrics) }
            payload.gpuMetrics.map { processGPUMetric($0, into: &metrics) }
            payload.locationActivityMetrics.map { processLocationMetric($0, into: &metrics) }
            payload.networkTransferMetrics.map { processNetworkTransferMetric($0, into: &metrics) }
            payload.signpostMetrics.map { $0.forEach { processSignpostMetrics($0, into: &metrics) } }

            let payloadMemoir = TracedMemoir(
                tracer: .label("metricPayloads.\(UUID().uuidString)"),
                meta: meta(for: payload),
                memoir: memoir
            )
            metrics
                .filter { _, data in !data.value.isZero }
                .forEach { name, data in
                    let (value, meta) = data
                    payloadMemoir.measurement(name: name, value: value, meta: meta)
                }
        }
    }

    private func meta(for payload: MXMetricPayload) -> [String: SafeString] {
        let metaKeyLatestAppVersion = "latestAppVersion"
        let metaKeyIncludesMultipleAppVersions = "includesMultipleAppVersions"
        let metaKeyTimeStampBegin = "timeBegin"
        let metaKeyTimeStampEnd = "timeEnd"
        let metaKeyRegionFormat = "regionFormat"
        let metaKeyDeviceType = "deviceType"
        let metaKeyOSVersion = "osVersion"
        let metaKeyApplicationBuildVersion = "applicationBuildVersion"
        let metaKeyPlatformArchitecture = "platformArchitecture"

        var meta: [String: SafeString] = [:]
        meta[metaKeyLatestAppVersion] = "\(safe: payload.latestApplicationVersion)"
        meta[metaKeyIncludesMultipleAppVersions] = "\(safe: payload.includesMultipleApplicationVersions)"
        meta[metaKeyTimeStampBegin] = "\(safe: payload.timeStampBegin)"
        meta[metaKeyTimeStampEnd] = "\(safe: payload.timeStampEnd)"
        if let metaData = payload.metaData {
            meta[metaKeyRegionFormat] = "\(safe: metaData.regionFormat)"
            meta[metaKeyOSVersion] = "\(safe: metaData.osVersion)"
            meta[metaKeyApplicationBuildVersion] = "\(safe: metaData.applicationBuildVersion)"
            if #available(iOS 14.0, *) {
                meta[metaKeyPlatformArchitecture] = "\(safe: metaData.platformArchitecture)"
            }
            meta[metaKeyDeviceType] = "\(safe: metaData.deviceType)"
        }
        return meta
    }

    @available(iOS 14.0, *)
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        let metaKeyTimeStampBegin = "timeBegin"
        let metaKeyTimeStampEnd = "timeEnd"

        let keyCrash: SafeString = "iOSMetric.diagnostics.crash"
        let keyCPUException: SafeString = "iOSMetric.diagnostics.cpuException"
        let keyHang: SafeString = "iOSMetric.diagnostics.hang"
        let keyDiskWriteException: SafeString = "iOSMetric.diagnostics.diskWriteException"

        payloads.forEach { payload in
            var meta: [String: SafeString] = [:]
            meta[metaKeyTimeStampBegin] = "\(safe: payload.timeStampBegin)"
            meta[metaKeyTimeStampEnd] = "\(safe: payload.timeStampEnd)"

            let payloadMemoir = TracedMemoir(
                tracer: .label("metricDiagnostics.\(UUID().uuidString)"),
                meta: meta,
                memoir: memoir
            )

            payload.crashDiagnostics?
                .map(metaFor(crash:))
                .forEach { payloadMemoir.critical(keyCrash, meta: $0) }
            payload.cpuExceptionDiagnostics?
                .map(metaFor(cpuException:))
                .forEach { payloadMemoir.critical(keyCPUException, meta: $0) }
            payload.hangDiagnostics?
                .map(metaFor(hang:))
                .forEach { payloadMemoir.error(keyHang, meta: $0) }
            payload.diskWriteExceptionDiagnostics?
                .map(metaFor(diskWriteException:))
                .forEach { payloadMemoir.error(keyDiskWriteException, meta: $0) }
        }
    }

    private func rangeInSeconds(for bucket: MXHistogramBucket<UnitDuration>) -> Range<Double> {
        let start: Double = bucket.bucketStart.converted(to: .seconds).value
        let end: Double = bucket.bucketEnd.converted(to: .seconds).value
        return start ..< end
    }

    private func rangeOfBars(for bucket: MXHistogramBucket<MXUnitSignalBars>) -> Range<Double> {
        let start: Double = bucket.bucketStart.value
        let end: Double = bucket.bucketEnd.value
        return start ..< end
    }
}

#endif
