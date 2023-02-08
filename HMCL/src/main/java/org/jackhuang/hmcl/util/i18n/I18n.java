/*
 * Hello Minecraft! Launcher
 * Copyright (C) 2020  huangyuhui <huanghongxun2008@126.com> and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
package org.jackhuang.hmcl.util.i18n;

import org.jackhuang.hmcl.util.i18n.Locales.SupportedLocale;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.Properties;
import java.util.ResourceBundle;
import java.util.logging.Level;

import static org.jackhuang.hmcl.util.Logging.LOG;

public final class I18n {

    private I18n() {
    }

    public static SupportedLocale getCurrentLocale() {
        return Locales.ZH_CN;
    }

    public static ResourceBundle getResourceBundle() {
        return getCurrentLocale().getResourceBundle();
    }

    private static Properties loadMessages(String path) {
        Properties messages = new Properties();
        try (Reader reader = new InputStreamReader(I18n.class.getResourceAsStream(path), StandardCharsets.UTF_8)) {
            messages.load(reader);
        } catch (IOException e) {
            LOG.log(Level.WARNING, "Failed to load " + path, e);
        }
        return messages;
    }

    private static final Properties defaultMessages = loadMessages("/assets/lang/I18N_zh_CN.properties");
    private static final Properties overrideMessages = loadMessages("/assets/lang/I18N_override.properties");

    public static String i18n(String key, Object... formatArgs) {
        return String.format(i18n(key), formatArgs);
    }

    public static String i18n(String key) {
        String message = overrideMessages.getProperty(key);
        if (message == null)
            message = defaultMessages.getProperty(key);
        if (message == null) {
            LOG.log(Level.SEVERE, "Cannot find key " + key + " in resource bundle");
            message = key;
        }
        return message;
    }

    public static boolean hasKey(String key) {
        try {
            getResourceBundle().getString(key);
            return true;
        } catch (MissingResourceException e) {
            return false;
        }
    }
}
