package expo.modules.amap

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.ConcurrentHashMap
import kotlinx.coroutines.launch

sealed class ImageSource {
    data class LocalName(val name: String) : ImageSource()
    data class RemoteURL(val url: URL) : ImageSource()
    data class Base64(val data: String) : ImageSource()
}

object ImageCache {
    private val cache = ConcurrentHashMap<String, Bitmap>()

    fun get(key: String): Bitmap? = cache[key]

    fun set(key: String, bitmap: Bitmap) {
        cache[key] = bitmap
    }
}

object ImageLoader {
    suspend fun from(value: Any?): Bitmap? {
        if (value == null) return null

        val key: String
        val source: ImageSource

        when (value) {
            is String -> {
                key = value
                source = when {
                    value.startsWith("data:image") -> ImageSource.Base64(value)
                    value.startsWith("http://") || value.startsWith("https://") -> {
                        val url = URL(value)
                        ImageSource.RemoteURL(url)
                    }
                    else -> ImageSource.LocalName(value)
                }
            }
            else -> return null
        }

        ImageCache.get(key)?.let { return it }

        val bitmap = when (source) {
            is ImageSource.Base64 -> {
                val base64Data = source.data.substringAfter(",")
                val bytes = Base64.decode(base64Data, Base64.DEFAULT)
                BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            }

            is ImageSource.RemoteURL -> {
                withContext(Dispatchers.IO) {
                    try {
                        val conn = source.url.openConnection() as HttpURLConnection
                        conn.connect()
                        val input = conn.inputStream
                        BitmapFactory.decodeStream(input).also { input.close() }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        null
                    }
                }
            }

            is ImageSource.LocalName -> {
                // 先尝试 assets/bundle 中的资源
                val file = File(source.name)
                if (file.exists()) {
                    BitmapFactory.decodeFile(source.name)
                } else {
                    null
                }
            }
        }

        bitmap?.let { ImageCache.set(key, it) }
        return bitmap
    }

    suspend fun loadMultiple(values: List<Any?>): List<Bitmap?> = coroutineScope {
        val deferreds = values.mapIndexed { index, value ->
            async { index to from(value) }
        }
        val results = MutableList<Bitmap?>(values.size) { null }
        for (d in deferreds) {
            val (index, bmp) = d.await()
            results[index] = bmp
        }
        results
    }

    fun from(value: Any?, completion: (Bitmap?) -> Unit) {
        GlobalScope.launch(Dispatchers.Main) {
            val bmp = from(value)
            completion(bmp)
        }
    }

    fun loadMultiple(values: List<Any?>, completion: (List<Bitmap?>) -> Unit) {
        GlobalScope.launch(Dispatchers.Main) {
            val results = mutableListOf<Bitmap?>()
            for (v in values) {
                results.add(from(v))
            }
            completion(results)
        }
    }
}
