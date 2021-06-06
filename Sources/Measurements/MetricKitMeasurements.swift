//
// MetricKitAppMetrics
// Memoirs
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation
import MemoirSubscriptions

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

    private let metaKeyLatestApplicationVersion: String = "iOS.metrics.latestApplicationVersion"
    private let metaKeyIncludesMultipleApplicationVersions: String = "iOS.metrics.includesMultipleApplicationVersions"
    private let metaKeyTimeStampBegin: String = "iOS.metrics.timeStampBegin"
    private let metaKeyTimeStampEnd: String = "iOS.metrics.timeStampEnd"
    private let metaKeyRegionFormat: String = "iOS.metrics.metaRegionFormat"
    private let metaKeyDeviceType: String = "iOS.metrics.metaDeviceType"
    private let metaKeyOSVersion: String = "iOS.metrics.metaOSVersion"
    private let metaKeyApplicationBuildVersion: String = "iOS.metrics.metaApplicationBuildVersion"
    private let metaKeyPlatformArchitecture: String = "iOS.metrics.metaPlatformArchitecture"

    private let keyCPUCumulativeTime: String = "iOS.metrics.cpu.cumulativeTime.secs"
    private let keyCPUCumulativeInstructions: String = "iOS.metrics.cpu.cumulativeInstructions.secs"

    private let keyMemoryAverageSuspendedMemory: String = "iOS.metrics.memory.averageSuspendedMemory.bytes"
    private let keyMemoryPeakUsage: String = "iOS.metrics.memory.peakMemoryUsage.bytes"

    private let keyAnimationScrollHitchTimeRatio: String = "iOS.metrics.animation.keyAnimationScrollHitchTimeRatio"

    private let keyExitsBackgroundNormal: String = "iOS.metrics.exits.background.normal"
    private let keyExitsBackgroundAbnormal: String = "iOS.metrics.exits.background.abnormal"
    private let keyExitsBackgroundWatchdog: String = "iOS.metrics.exits.background.watchdog"
    private let keyExitsBackgroundTaskAssertion: String = "iOS.metrics.exits.background.taskAssertion"
    private let keyExitsBackgroundBadAccess: String = "iOS.metrics.exits.background.badAccess"
    private let keyExitsBackgroundCPULimit: String = "iOS.metrics.exits.background.cpuLimit"
    private let keyExitsBackgroundIllegalInstruction: String = "iOS.metrics.exits.background.illegalInstruction"
    private let keyExitsBackgroundMemoryPressure: String = "iOS.metrics.exits.background.memoryPressure"
    private let keyExitsBackgroundMemoryResource: String = "iOS.metrics.exits.background.memoryResource"
    private let keyExitsBackgroundLockedFile: String = "iOS.metrics.exits.background.lockedFile"

    private let keyExitsForegroundNormal: String = "iOS.metrics.exits.foreground.normal"
    private let keyExitsForegroundAbnormal: String = "iOS.metrics.exits.foreground.abnormal"
    private let keyExitsForegroundWatchdog: String = "iOS.metrics.exits.foreground.watchdog"
    private let keyExitsForegroundBadAccess: String = "iOS.metrics.exits.foreground.badAccess"
    private let keyExitsForegroundIllegalInstruction: String = "iOS.metrics.exits.foreground.illegalInstruction"
    private let keyExitsForegroundResourceLimit: String = "iOS.metrics.exits.foreground.resourceLimit"

    private let keyLaunchTimeToFirstDraw: String = "iOS.metrics.launch.timeToFirstDraw.secs"
    private let keyLaunchResumeTime: String = "iOS.metrics.launch.resumeTime.secs"

    private let keyResponsivenessHangTime: String = "iOS.metrics.responsiveness.hangTime.secs"

    private let keyCellularConditionTime: String = "iOS.metrics.cellular.conditionTime.bars"

    private let keyTimeMetricsForeground: String = "iOS.metrics.appTime.foreground"
    private let keyTimeMetricsBackground: String = "iOS.metrics.appTime.background"
    private let keyTimeMetricsBackgroundAudio: String = "iOS.metrics.appTime.background.audio"
    private let keyTimeMetricsBackgroundLocation: String = "iOS.metrics.appTime.background.location"

    private let keyDiskWrites: String = "iOS.metrics.disk.writes.bytes"

    private let keyDisplayAverageLuminance: String = "iOS.metrics.display.luminance.average.apl"

    private let keyGPUTime: String = "iOS.metrics.gpu.time.secs"

    private let keyLocationNavigation: String = "iOS.metrics.location.navigation.secs"
    private let keyLocationBest: String = "iOS.metrics.location.best.secs"
    private let keyLocationTenMeters: String = "iOS.metrics.location.tenMeters.secs"
    private let keyLocationHundredMeters: String = "iOS.metrics.location.hundredMeters.secs"
    private let keyLocationKilometer: String = "iOS.metrics.location.kilometer.secs"
    private let keyLocationThreeKilometers: String = "iOS.metrics.location.threeKilometers.secs"

    private let keyNetworkWifiUpload: String = "iOS.metrics.net.WifiUpload.bytes"
    private let keyNetworkWifiDownload: String = "iOS.metrics.net.WifiDownload.bytes"
    private let keyNetworkCellularUpload: String = "iOS.metrics.net.cellularUpload.bytes"
    private let keyNetworkCellularDownload: String = "iOS.metrics.net.cellularDownload.bytes"

    private let keySignpostPrefix: String = "iOS.metrics.sp."

    public func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach { payload in
            var meta: [String: SafeString] = [:]
            meta[metaKeyLatestApplicationVersion] = "\(safe: payload.latestApplicationVersion)"
            meta[metaKeyIncludesMultipleApplicationVersions] = "\(safe: payload.includesMultipleApplicationVersions)"
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

            var metrics: [String: MeasurementValue] = [:]
            if let metric = payload.cpuMetrics {
                metrics[keyCPUCumulativeTime] = .int(Int64(metric.cumulativeCPUTime.converted(to: .seconds).value))
                if #available(iOS 14.0, *) {
                    metrics[keyCPUCumulativeInstructions] = .int(Int64(metric.cumulativeCPUInstructions.value))
                }
            }
            if let metric = payload.memoryMetrics {
                metrics[keyMemoryAverageSuspendedMemory] = .int(Int64(metric.averageSuspendedMemory.averageMeasurement.converted(to: .bytes).value))
                metrics[keyMemoryPeakUsage] = .int(Int64(metric.peakMemoryUsage.converted(to: .bytes).value))
            }
            if #available(iOS 14.0, *) {
                if let metric = payload.animationMetrics {
                    metrics[keyAnimationScrollHitchTimeRatio] = .double(metric.scrollHitchTimeRatio.value)
                }
                if let metric = payload.applicationExitMetrics {
                    metrics[keyExitsBackgroundNormal] = .int(Int64(metric.backgroundExitData.cumulativeNormalAppExitCount))
                    metrics[keyExitsBackgroundAbnormal] = .int(Int64(metric.backgroundExitData.cumulativeAbnormalExitCount))
                    metrics[keyExitsBackgroundWatchdog] = .int(Int64(metric.backgroundExitData.cumulativeAppWatchdogExitCount))
                    metrics[keyExitsBackgroundTaskAssertion] = .int(Int64(metric.backgroundExitData.cumulativeBackgroundTaskAssertionTimeoutExitCount))
                    metrics[keyExitsBackgroundBadAccess] = .int(Int64(metric.backgroundExitData.cumulativeBadAccessExitCount))
                    metrics[keyExitsBackgroundCPULimit] = .int(Int64(metric.backgroundExitData.cumulativeCPUResourceLimitExitCount))
                    metrics[keyExitsBackgroundIllegalInstruction] = .int(Int64(metric.backgroundExitData.cumulativeIllegalInstructionExitCount))
                    metrics[keyExitsBackgroundMemoryPressure] = .int(Int64(metric.backgroundExitData.cumulativeMemoryPressureExitCount))
                    metrics[keyExitsBackgroundMemoryResource] = .int(Int64(metric.backgroundExitData.cumulativeMemoryResourceLimitExitCount))
                    metrics[keyExitsBackgroundLockedFile] = .int(Int64(metric.backgroundExitData.cumulativeSuspendedWithLockedFileExitCount))

                    metrics[keyExitsForegroundNormal] = .int(Int64(metric.foregroundExitData.cumulativeNormalAppExitCount))
                    metrics[keyExitsForegroundAbnormal] = .int(Int64(metric.foregroundExitData.cumulativeAbnormalExitCount))
                    metrics[keyExitsForegroundWatchdog] = .int(Int64(metric.foregroundExitData.cumulativeAppWatchdogExitCount))
                    metrics[keyExitsForegroundBadAccess] = .int(Int64(metric.foregroundExitData.cumulativeBadAccessExitCount))
                    metrics[keyExitsForegroundIllegalInstruction] = .int(Int64(metric.foregroundExitData.cumulativeIllegalInstructionExitCount))
                    metrics[keyExitsForegroundResourceLimit] = .int(Int64(metric.foregroundExitData.cumulativeMemoryResourceLimitExitCount))
                }
            }
            if let metric = payload.applicationLaunchMetrics {
                let bucketsTimeToFirstDraw: [MeasurementValue.HistogramBucket] = metric.histogrammedTimeToFirstDraw
                    .bucketEnumerator
                    .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
                    .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
                metrics[keyLaunchTimeToFirstDraw] = .histogram(buckets: bucketsTimeToFirstDraw)
                let bucketsResumeTime: [MeasurementValue.HistogramBucket] = metric.histogrammedApplicationResumeTime
                    .bucketEnumerator
                    .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
                    .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
                metrics[keyLaunchResumeTime] = .histogram(buckets: bucketsResumeTime)
            }
            if let metric = payload.applicationResponsivenessMetrics {
                let buckets: [MeasurementValue.HistogramBucket] = metric.histogrammedApplicationHangTime
                    .bucketEnumerator
                    .compactMap { $0 as? MXHistogramBucket<UnitDuration> }
                    .map { MeasurementValue.HistogramBucket(range: rangeInSeconds(for: $0), count: $0.bucketCount) }
                metrics[keyResponsivenessHangTime] = .histogram(buckets: buckets)
            }
            if let metric = payload.applicationTimeMetrics {
                metrics[keyTimeMetricsForeground] = .double(metric.cumulativeForegroundTime.converted(to: .seconds).value)
                metrics[keyTimeMetricsBackground] = .double(metric.cumulativeBackgroundTime.converted(to: .seconds).value)
                metrics[keyTimeMetricsBackgroundAudio] = .double(metric.cumulativeBackgroundAudioTime.converted(to: .seconds).value)
                metrics[keyTimeMetricsBackgroundLocation] = .double(metric.cumulativeBackgroundLocationTime.converted(to: .seconds).value)
            }
            if let metric = payload.cellularConditionMetrics {
                let buckets: [MeasurementValue.HistogramBucket] = metric.histogrammedCellularConditionTime
                    .bucketEnumerator
                    .compactMap { $0 as? MXHistogramBucket<MXUnitSignalBars> }
                    .map { MeasurementValue.HistogramBucket(range: rangeOfBars(for: $0), count: $0.bucketCount) }
                metrics[keyCellularConditionTime] = .histogram(buckets: buckets)
            }
            if let metric = payload.diskIOMetrics {
                metrics[keyDiskWrites] = .double(metric.cumulativeLogicalWrites.converted(to: .bytes).value)
            }
            if let metric = payload.displayMetrics {
                if let value = metric.averagePixelLuminance?.averageMeasurement.converted(to: .apl).value {
                    metrics[keyDisplayAverageLuminance] = .double(value)
                }
            }
            if let metric = payload.gpuMetrics {
                metrics[keyGPUTime] = .double(metric.cumulativeGPUTime.converted(to: .seconds).value)
            }
            if let metric = payload.locationActivityMetrics {
                metrics[keyLocationNavigation] = .double(metric.cumulativeBestAccuracyForNavigationTime.converted(to: .seconds).value)
                metrics[keyLocationBest] = .double(metric.cumulativeBestAccuracyTime.converted(to: .seconds).value)
                metrics[keyLocationTenMeters] = .double(metric.cumulativeNearestTenMetersAccuracyTime.converted(to: .seconds).value)
                metrics[keyLocationHundredMeters] = .double(metric.cumulativeHundredMetersAccuracyTime.converted(to: .seconds).value)
                metrics[keyLocationKilometer] = .double(metric.cumulativeKilometerAccuracyTime.converted(to: .seconds).value)
                metrics[keyLocationThreeKilometers] = .double(metric.cumulativeThreeKilometersAccuracyTime.converted(to: .seconds).value)
            }
            if let metric = payload.networkTransferMetrics {
                metrics[keyNetworkWifiUpload] = .int(Int64(metric.cumulativeWifiUpload.converted(to: .bytes).value))
                metrics[keyNetworkWifiDownload] = .int(Int64(metric.cumulativeWifiDownload.converted(to: .bytes).value))
                metrics[keyNetworkCellularUpload] = .int(Int64(metric.cumulativeCellularUpload.converted(to: .bytes).value))
                metrics[keyNetworkCellularDownload] = .int(Int64(metric.cumulativeCellularDownload.converted(to: .bytes).value))
            }
            if let metric = payload.signpostMetrics {
                metric.forEach { metric in
                    let prefix = "\(keySignpostPrefix)\(metric.signpostCategory).\(metric.signpostName)"
                    metrics["\(prefix).count"] = .int(Int64(metric.totalCount))
                    if let interval = metric.signpostIntervalData {
                        if let value = interval.cumulativeCPUTime?.converted(to: .seconds).value {
                            metrics["\(prefix).cumulativeCPU.secs"] = .double(value)
                        }
                        if let value = interval.averageMemory?.averageMeasurement.converted(to: .bytes).value {
                            metrics["\(prefix).averageMemory.bytes"] = .double(value)
                        }
                        // TODO: Output histogram with durations
                    }
                }
            }

            let payloadMemoir = TracedMemoir(
                tracer: .label("metricPayloads.\(payload.timeStampBegin)/\(payload.timeStampEnd)"),
                meta: meta,
                memoir: memoir
            )
            metrics
                .filter { _, value in !value.isZero }
                .forEach { key, value in
                    payloadMemoir.measurement(name: key, value: value)
                }
        }
    }

    @available(iOS 14.0, *)
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        payloads.forEach { payload in
            var meta: [String: SafeString] = [:]
            meta[metaKeyTimeStampBegin] = "\(safe: payload.timeStampBegin)"
            meta[metaKeyTimeStampEnd] = "\(safe: payload.timeStampEnd)"

            let payloadMemoir = TracedMemoir(
                tracer: .label("metricDiagnostics.\(payload.timeStampBegin)/\(payload.timeStampEnd)"),
                meta: meta,
                memoir: memoir
            )

            payload.crashDiagnostics?
                .map { diagnostic in
                    var diagnosticMeta: [String: SafeString] = [:]
                    diagnosticMeta["type"] = diagnostic.exceptionType.map { "\(safe: $0)" }
                    diagnosticMeta["code"] = diagnostic.exceptionCode.map { "\(safe: $0)" }
                    diagnosticMeta["signal"] = diagnostic.signal.map { "\(safe: $0)" }
                    diagnosticMeta["reason"] = diagnostic.terminationReason.map { "\(safe: $0)" }
                    diagnosticMeta["memoryRegion"] = diagnostic.virtualMemoryRegionInfo.map { "\(safe: $0)" }
                    let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
                    diagnosticMeta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
                    return diagnosticMeta
                }
                .forEach {
                    payloadMemoir.critical("MetricKit.crash", meta: $0)
                }
            payload.cpuExceptionDiagnostics?
                .map { diagnostic in
                    var diagnosticMeta: [String: SafeString] = [:]
                    diagnosticMeta["totalCPU.secs"] = "\(safe: diagnostic.totalCPUTime.converted(to: .seconds).value)"
                    diagnosticMeta["totalSampled.secs"] = "\(safe: diagnostic.totalSampledTime.converted(to: .seconds).value)"
                    let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
                    diagnosticMeta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
                    return diagnosticMeta
                }
                .forEach {
                    payloadMemoir.critical("MetricKit.CPUException", meta: $0)
                }
            payload.hangDiagnostics?
                .map { diagnostic in
                    var diagnosticMeta: [String: SafeString] = [:]
                    diagnosticMeta["duration.secs"] = "\(safe: diagnostic.hangDuration.converted(to: .seconds).value)"
                    let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
                    diagnosticMeta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
                    return diagnosticMeta
                }
                .forEach {
                    payloadMemoir.error("MetricKit.hang", meta: $0)
                }
            payload.diskWriteExceptionDiagnostics?
                .map { diagnostic in
                    var diagnosticMeta: [String: SafeString] = [:]
                    diagnosticMeta["total.bytes"] = "\(safe: diagnostic.totalWritesCaused.converted(to: .bytes).value)"
                    let stackTraceData = diagnostic.callStackTree.jsonRepresentation()
                    diagnosticMeta["stack"] = String(data: stackTraceData, encoding: .utf8).map { "\(safe: $0)" }
                    return diagnosticMeta
                }
                .forEach {
                    payloadMemoir.error("MetricKit.diskWrite", meta: $0)
                }
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
