export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="max-w-5xl w-full">
        <h1 className="text-6xl font-bold text-center mb-8">
          Welcome to ARgument
        </h1>
        <p className="text-xl text-center text-gray-600 mb-12">
          WebAR Video Overlay Service - Create interactive AR experiences
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="p-6 border rounded-lg hover:shadow-lg transition">
            <h2 className="text-2xl font-semibold mb-4">Upload Images</h2>
            <p className="text-gray-600">
              Upload your images to use as AR markers
            </p>
          </div>
          <div className="p-6 border rounded-lg hover:shadow-lg transition">
            <h2 className="text-2xl font-semibold mb-4">Add Videos</h2>
            <p className="text-gray-600">
              Upload videos to overlay on your images
            </p>
          </div>
          <div className="p-6 border rounded-lg hover:shadow-lg transition">
            <h2 className="text-2xl font-semibold mb-4">Share AR Links</h2>
            <p className="text-gray-600">
              Generate links to view your AR content
            </p>
          </div>
        </div>
      </div>
    </main>
  )
}
