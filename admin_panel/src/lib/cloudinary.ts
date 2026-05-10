import { envConfig } from '../config/env'

type UploadResult = {
  secureUrl: string
}

type CloudinaryResourceType = 'video' | 'raw'

type PresetType = 'audio' | 'transcript'

function presetFor(type: PresetType): string {
  return type === 'audio' ? envConfig.cloudinary.audioUploadPreset : envConfig.cloudinary.transcriptUploadPreset
}

function uploadToCloudinary(
  file: File,
  resourceType: CloudinaryResourceType,
  presetType: PresetType,
  onProgress: (percent: number) => void,
): Promise<UploadResult> {
  return new Promise((resolve, reject) => {
    const endpoint = `https://api.cloudinary.com/v1_1/${envConfig.cloudinary.cloudName}/${resourceType}/upload`
    const formData = new FormData()
    formData.append('file', file)
    formData.append('upload_preset', presetFor(presetType))

    const request = new XMLHttpRequest()

    request.upload.onprogress = (event) => {
      if (!event.lengthComputable) return
      const percent = Math.round((event.loaded / event.total) * 100)
      onProgress(percent)
    }

    request.onerror = () => reject(new Error('Cloudinary upload failed due to a network error.'))

    request.onload = () => {
      if (request.status < 200 || request.status >= 300) {
        reject(new Error(`Cloudinary upload failed with status ${request.status}.`))
        return
      }

      const response = JSON.parse(request.responseText) as { secure_url?: string }
      if (!response.secure_url) {
        reject(new Error('Cloudinary upload did not return secure_url.'))
        return
      }

      resolve({ secureUrl: response.secure_url })
    }

    request.open('POST', endpoint)
    request.send(formData)
  })
}

export function uploadAudioToCloudinary(file: File, onProgress: (percent: number) => void): Promise<UploadResult> {
  return uploadToCloudinary(file, 'video', 'audio', onProgress)
}

export function uploadTranscriptJsonToCloudinary(
  jsonText: string,
  filename: string,
  onProgress: (percent: number) => void,
): Promise<UploadResult> {
  const file = new File([jsonText], filename, { type: 'application/json' })
  return uploadToCloudinary(file, 'raw', 'transcript', onProgress)
}
