export type UpdateMessage = {
  title: string
  body: string
  primaryButton: string
  secondaryButton?: string
}

export type RemoteConfig = {
  versions: {
    latest: number
    minorUpdate: number | null
    forceUpdate: number | null
  }
  messages: {
    minorUpdate: UpdateMessage
    forceUpdate: Omit<UpdateMessage, 'secondaryButton'>
    maintenance: Omit<UpdateMessage, 'secondaryButton'>
  }
  maintenance: {
    enabled: boolean
  }
  storeUrl: {
    android: string
    ios: string
  }
  features: {
    hukamnamaEnabled: boolean
  }
  updatedAt?: unknown
  updatedBy?: string
}

export type MenuSettings = {
  enabledItems: string[]
  updatedAt?: unknown
  updatedBy?: string
}

export const DEFAULT_REMOTE_CONFIG: RemoteConfig = {
  versions: {
    latest: 5,
    minorUpdate: 4,
    forceUpdate: 3,
  },
  messages: {
    minorUpdate: {
      title: 'Update Available',
      body: 'New improvements and fixes are available.',
      primaryButton: 'Update',
      secondaryButton: 'Skip for now',
    },
    forceUpdate: {
      title: 'Update Required',
      body: 'Please update the app to continue using Bani Sagar.',
      primaryButton: 'Update App',
    },
    maintenance: {
      title: 'Maintenance Mode',
      body: 'Bani Sagar is temporarily under maintenance.',
      primaryButton: 'Close App',
    },
  },
  maintenance: {
    enabled: false,
  },
  storeUrl: {
    android: '',
    ios: '',
  },
  features: {
    hukamnamaEnabled: true,
  },
}

export const DEFAULT_MENU_SETTINGS: MenuSettings = {
  enabledItems: ['notifications', 'settings', 'language', 'share', 'feedback', 'rate', 'exit'],
}
