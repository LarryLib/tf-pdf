package com.example.tf_pdf

import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.pdf.PdfDocument
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.util.Size
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.OutputStream

private val mainThreadHandler = Handler(Looper.getMainLooper())

class TfPdfPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "tf_pdf_channel")
            channel.setMethodCallHandler(TfPdfPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "createPDFByImage" -> {
                var savePath = call.argument<String>("savePath")
                val imagePaths = call.argument<List<String>>("imagePaths")!!
                val width = call.argument<Int>("width")!!
                val height = call.argument<Int>("height")!!

                if (savePath == null) {
                    val root = Environment.getExternalStorageDirectory()
                    savePath = root.path + "/new.pdf"
                }

                Thread {
                    createPDF(imagePaths, Size(width, height), File(savePath))
                    mainThreadHandler.post { result.success(savePath) }
                }.start()
            }
            else -> result.notImplemented()
        }
    }

    fun createPDF(imagePaths: List<String>, size: Size, file: File) {

        //先创建一个 PdfDocument 对象 document
        val document = PdfDocument()

        //创建 PageInfo 对象，用于描述 PDF 中单个的页面
        val pageInfo = PdfDocument.PageInfo.Builder(size.width, size.height, imagePaths.count()).create()

        // 加入 page
        for (path in imagePaths) {
            Log.d("加入 page", "path ${path}")
            //  拿到图片
            val imageBytes = File(path).readBytes()
            Log.d("加入 page", "imageBytes ${imageBytes.size}")
            var bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

            //  开始启动内容填写
            var page = document.startPage(pageInfo)

            //  绘制页面，主要是从page 中获取一个 Canvas 对象。
            page.canvas.drawBitmap(bitmap, Matrix(), Paint())

            //  停止对页面的填写
            document.finishPage(page)
        }

        //  将文件写入流
        document.writeTo(outputStream(file))

        //  关闭流
        document.close()
    }

    fun outputStream(file: File): OutputStream? {
        try {
            val os = FileOutputStream(file)
            return os
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        }
        return null
    }
}
