export type VersionControlConfig = {
  latestBuild: number
  minimumSupportedBuild: number
  latestVersionName: string
  forceUpdate: boolean
  updateMessage: string
  androidStoreUrl: string
  iosStoreUrl: string
}

export type MaintenanceConfig = {
  isUnderMaintenance: boolean
  maintenanceMessage: string
}

export type LanguageFlags = {
  punjabi: boolean
  english: boolean
  hindi: boolean
}

export type FeatureFlagsConfig = {
  languages: LanguageFlags
  focus_reading_mode: boolean
  new_player_ui: boolean
  experimental_home: boolean
}

export type RemoteConfig = {
  appName: string
  environment: 'Production' | 'Staging' | 'Development'
  versionControl: VersionControlConfig
  maintenance: MaintenanceConfig
  featureFlags: FeatureFlagsConfig
  updatedAt?: unknown
  updatedBy?: string
}

export const DEFAULT_REMOTE_CONFIG: RemoteConfig = {
  appName: 'Bani Sagar',
  environment: 'Production',
  versionControl: {
    latestBuild: 6,
    minimumSupportedBuild: 5,
    latestVersionName: '1.0.1',
    forceUpdate: false,
    updateMessage: 'New immersive reading improvements available.',
    androidStoreUrl: 'https://play.google.com/store/apps/details?id=com.banisagar',
    iosStoreUrl: 'https://apps.apple.com/app/id0000000000',
  },
  maintenance: {
    isUnderMaintenance: false,
    maintenanceMessage: 'Scheduled improvements in progress.',
  },
  featureFlags: {
    languages: {
      punjabi: true,
      english: false,
      hindi: false,
    },
    focus_reading_mode: false,
    new_player_ui: false,
    experimental_home: false,
  },
}
