/*******************************************************************************
 * Copyright 2006-2016 TyTech B.V., Saturnusstraat 60, 2516 AH, The Hague, The Netherlands All rights reserved. This software is proprietary
 * information of TyTech B.V..
 ******************************************************************************/
package nl.tytech.core.item.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * ClassList
 * <p>
 * Only objects of this class are used in this list.
 * <p>
 * 
 * 
 * @author Maxim Knepfle
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.FIELD })
public @interface ListOfClass {

    /**
     * Only objects of this class are used in this list.
     * 
     * @return
     */
    Class<?> value();
}
