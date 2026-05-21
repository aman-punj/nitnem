package com.banisagar.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.banisagar.app.R

class HukamnamaWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(
                "HomeWidgetPreferences", Context.MODE_PRIVATE
            )
            val gurmukhi = prefs.getString(
                "hukamnama_gurmukhi",
                "ਹੁਕਮਨਾਮਾ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…"
            ) ?: "ਹੁਕਮਨਾਮਾ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…"
            val date = prefs.getString("hukamnama_date", "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.hukamnama_widget)
            views.setTextViewText(R.id.widget_gurmukhi, gurmukhi)
            views.setTextViewText(R.id.widget_date, date)

            // Tap opens the app and routes to the Hukamnama detail sheet
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                data = Uri.parse("banisagar://hukamnama")
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
